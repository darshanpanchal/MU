
//
//  NotificationsView.swift
//  mindsUnlimited
//
//  Created by IPS on 23/05/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit
import UserNotifications
class NotificationsView: GeneralViewController,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,customAlertDelegates {
    
    //MARK: Class properties 
 
    var unReadNotifications = [NotiticationModel]()
    var readNotifications = [NotiticationModel]()
    
    let cellId = "cellId"
    let cellId1 = "cellId1"
    let headerId = "headerId"
    lazy var collectionView:UICollectionView={
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        cv.backgroundColor = .clear
        cv.bounces = true
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.register(CellForNotificationDetails.self, forCellWithReuseIdentifier: self.cellId)
        
        cv.register(Cell_for_new_notification.self, forCellWithReuseIdentifier: self.cellId1)
        
       
        cv.register(HeaderForMeditationCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.headerId)
        
        return cv
    }()
    
    
    //MARK: Life cycle methods
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "sidemenu.title.notification").uppercased()
        
        self.setUpViews()
      
        self.setUpNatificaiton()
        
      
    }
   
    
    //MARK: Class methods
    
    func setUpNatificaiton(){
        if let offlineReadNotifications = UserDefaults.standard.object(forKey: "offlineReadNotifications") as? [Int]{
            
            if Reachability.isAvailable(){
                if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
                    let params = ["ReadNotificationIds":offlineReadNotifications]
                    ApiRequst.doRequest(requestType: .PUT, queryString: "users/\(userId)/notifications/read", parameter: params as [String : AnyObject], showHUD: false, completionHandler: { (json) in
                        
                        UserDefaults.standard.removeObject(forKey: "offlineReadNotifications")
                        
                    })
                }
            }
            
        }
        
        if #available(iOS 10, *) {
            self.reloadDatasources()
        } else {
            
            _ = DBManger.dbGenericQuery(queryString: "DELETE FROM notifications where id NOT LIKE '%temp%'")
            NotificationsView.getNotificationFromSserver(notificationObj: self)
        }
      
    }
    
    func setUpViews(){
    
        self.backgroudImageView.addSubview(self.collectionView)
        self.backgroudImageView.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.collectionView.topAnchor.constraint(equalTo: self.customNavigationImageView.bottomAnchor, constant: 10).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.backgroudImageView.bottomAnchor, constant: -5).isActive = true
 
    }
    
    func reloadDatasources(){
        self.readNotifications.removeAll()
        self.unReadNotifications.removeAll()
        
        func populateData(hasRead:Bool,arr:[[String:AnyObject]]){
            for object in arr{
                
                let model = NotiticationModel()
                
                model.hasRead = String(hasRead)
                if let value = object["user_id"] as? String{
                    model.user_id = value
                }
                if let value = object["title"] as? String{
                    model.title = value
                }
                if let value = object["note"] as? String{
                    model.note = value
                }
                if let value = object["id"] as? String{
                    model.id = value
                }
                if var value = object["category"] as? String{
                    value = value.removeWhiteSpaces().lowercased()
                    model.category = value
                    if value.lowercased() == "reminder" || value.lowercased() == "friendrequest"{
                     
                        if let reqId = object["friend_request_id"] as? String,reqId != "notAvailable"{
                            if reqId.removeWhiteSpaces() != ""{
                                model.friendRequestId = reqId
                            }
                        }
                        
                    }else if value == "local_reminder"{
                        
                        model.title = Vocabulary.getWordFromKey(key: "daily_notification.popup.title").capitalizingFirstLetter()
                        model.note = "N/A"
                        
                        if let create_date = object["created_date"] as? String{
                            
                            let df1 = DateFormatter()
                            df1.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
                            let date1 = df1.date(from: create_date)
                            
                            if  date1 != nil{
                                
                                let df3 = DateFormatter()
                                df3.dateFormat = "d"
                                let notificationDay = df3.string(from: date1!)
                                let currentDay = df3.string(from: Date())
                                
                                
                                let df4 = DateFormatter()
                                df4.dateFormat = "HH:mm"
                                let timeOnly = df4.string(from: date1!)
                                
                                if notificationDay == currentDay{
                                    
                                    model.note = "\(Vocabulary.getWordFromKey(key: "notification.label.today_at").capitalizingFirstLetter()) \(timeOnly)"
                                    
                                }else if let intValnotificationDay = Int(notificationDay),let intCurrentDay = Int(currentDay),intValnotificationDay == (intCurrentDay-1){
                                    
                                    model.note = "\(Vocabulary.getWordFromKey(key: "notification.label.yesterday_yat").capitalizingFirstLetter()) \(timeOnly)"
                                    
                                } else{
                                    let df2 = DateFormatter()
                                    df2.dateFormat = "MMM d, HH:mm"
                                    let date2 = df2.string(from: date1!)
                                    model.note = "\(Vocabulary.getWordFromKey(key: "notification.label.on").capitalized) "+date2
                                }
                                
                            }
                            
                        }
                        
                    }else if value == "dailymsg"{
                        
                        model.title = Vocabulary.getWordFromKey(key: "general.daily_msg").uppercased()
                    }else {
                        model.title = Vocabulary.getWordFromKey(key: "dailymsg.popup.title").uppercased()
                    }
                    
                }
                if let value = object["created_date"] as? String{
                    model.created_date = value
                }
                if let value = object["target"] as? String{
                    model.target = value
                }
                if let value = object["url"] as? String,value.removeWhiteSpaces() != ""{
                    model.url = value
                }
                if hasRead{
                    self.readNotifications.append(model)
                }else{
                    self.unReadNotifications.append(model)
                }
            
            }
        }
        
        let unRead = DBManger.dbGenericQuery(queryString: "SELECT * FROM notifications where hasRead = 'false' ORDER BY created_date DESC")
        populateData(hasRead: false, arr: unRead)
        
        let read = DBManger.dbGenericQuery(queryString: "SELECT * FROM notifications where hasRead = 'true' ORDER BY created_date DESC")
        populateData(hasRead: true, arr: read)
        
        if unRead.count == 0 && read.count == 0{
            NotificationsView.getNotificationFromSserver(notificationObj: self)
        }else{
            self.collectionView.reloadData()
            self.makeNewNotificationBadgeClear()
        }
     
    }
    
    override func backButtonActionHandeler(){
        self.popToHomeView()
    }
    
    static func getNotificationFromSserver(notificationObj:NotificationsView?){
      
        if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
            
            let isFromNotificationView = notificationObj != nil ? true : false
            ApiRequst.doRequest(requestType: .POST, queryString: "users/\(userId)/notificationhistory", parameter: ["CreatedDate":"" as AnyObject], showHUD: isFromNotificationView, completionHandler: { (json) in
            
                if let arrayOfNotifcations = json["NotificationHistory"] as? [[String:AnyObject]]{
                    
                    for object in arrayOfNotifcations{
                        if let notId = object["Id"] as? Int{
                        
                            var category = ""
                            if let value = object["Category"] as? String{
                                category = value
                            }
                            var dateToInsert = Date()
                            if var dateCreated = object["CreatedDate"] as? String{
                               
                                let df = DateFormatter()
                                df.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                                if let tempDate = df.date(from: dateCreated){
                                    dateCreated = df.string(from: tempDate)
                                    let df1 = DateFormatter()
                                    df1.dateFormat = "MM/dd/yyy HH:mm:ss"
                                    if let dateToBeInserted = df1.date(from: df1.string(from: tempDate)){
                                        dateToInsert = dateToBeInserted
                                    }
                                }
                            }
                            var title = ""
                            if let value = object["Title"] as? String{
                                title = value
                            }
                            var note = ""
                            if let value = object["Note"] as? String{
                                note = value
                            }
                            var isRead = true
                            if let value = object["IsRead"],String(describing: value) == "0"{
                                isRead = false
                            }
                            
                            var isBadgeEnable = true
                            if let value = object["IsBadgeEnabled"],String(describing: value) == "0"{
                                isBadgeEnable = false
                            }
                            
                            DispatchQueue.main.async(execute: {
                                let _ = DBManger.dbGenericQuery(queryString: "INSERT INTO notifications(id,category,created_date,title,note,hasRead,is_badge_enabled) VALUES('\(notId)','\(category)','\(dateToInsert)','\(title.replacingOccurrences(of: "'", with: ""))','\(note.replacingOccurrences(of: "'", with: ""))','\(isRead)','\(isBadgeEnable)')")
                            })
                        }
                    }
                    
                    DispatchQueue.main.async(execute: {
                        
                        if isFromNotificationView{
                            
                            if arrayOfNotifcations.count != 0{
                                
                                notificationObj!.reloadDatasources()
                            
                            }else{
                                
                                notificationObj!.collectionView.reloadData()
                            }
                       
                        }else{
                            AppDelegate.setBadgeNumber()
                        }
                     
                    })
                    
                    
                    
                }
                
            })
        }
        
    }
    
    func makeNewNotificationBadgeClear(){
        
        let result = DBManger.dbGenericQuery(queryString: "SELECT * FROM notifications WHERE is_badge_enabled = '\(true)' AND hasRead = '\(false)'")
        var ids = [Int]()
        for object in result{
            if let id = object["id"] as? String,let intValue = Int(id){
                ids.append(intValue)
            }
        }
        let _ = DBManger.dbGenericQuery(queryString: "UPDATE notifications SET is_badge_enabled='\(false)'")
        AppDelegate.setBadgeNumber()
        
        guard let userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"] else {
            return
        }
        let params = ["ReadNotificationIds":ids]
        ApiRequst.doRequest(requestType: .PUT, queryString: "users/\(userId)/notifications/badge/disable", parameter: params as [String : AnyObject], showHUD: false) { (json) in
        }
        
       
        
    }
    
    //MARK: CollectionView delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        collectionView.removeNoDataLabel()
        if self.readNotifications.count == 0 && self.unReadNotifications.count == 0{
            collectionView.showNoDataFound(msg: Vocabulary.getWordFromKey(key: "notification.label_no_notificaion").capitalizingFirstLetter())
        }else if self.readNotifications.count != 0 && self.unReadNotifications.count != 0{
            return 2
        }
        
        return 1
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.readNotifications.count == 0 && self.unReadNotifications.count == 0{
            return 0
        }else if self.readNotifications.count != 0 && self.unReadNotifications.count != 0{
            if section == 0{
                return unReadNotifications.count
            }else{
                return readNotifications.count
            }
        }else if unReadNotifications.count != 0{
            return unReadNotifications.count
        }else {
            return readNotifications.count
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: DeviceType.isIpad() ? 90 : 65)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        return CGSize(width: self.collectionView.frame.width, height: DeviceType.isIpad() ? 65 : 40)
    }
   
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let history_cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! CellForNotificationDetails
        let new_cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId1, for: indexPath) as!
        Cell_for_new_notification
        if self.readNotifications.count != 0 && self.unReadNotifications.count != 0{
            if indexPath.section == 0{
                new_cell.cellAttibutes = self.unReadNotifications[indexPath.item]
                new_cell.referenceOfClass = self
                return new_cell
            }else{
                history_cell.cellAttibutes = self.readNotifications[indexPath.item]
                return history_cell
            }
        }else if unReadNotifications.count != 0{
            
            new_cell.cellAttibutes = self.unReadNotifications[indexPath.item]
            new_cell.referenceOfClass = self
            return new_cell
            
        }else {
            history_cell.cellAttibutes = self.readNotifications[indexPath.item]
            return history_cell
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.headerId, for: indexPath) as! HeaderForMeditationCell
       
        
        if self.readNotifications.count == 0 && self.unReadNotifications.count == 0{
             cell.titleLabel.text = ""
        }else if self.readNotifications.count != 0 && self.unReadNotifications.count != 0{
            if indexPath.section == 0{
                cell.titleLabel.text = Vocabulary.getWordFromKey(key: "notification.header.new").uppercased()
            }else{
                cell.titleLabel.text = Vocabulary.getWordFromKey(key: "notification.header.history").uppercased()
            }
        }else if unReadNotifications.count != 0{
             cell.titleLabel.text = Vocabulary.getWordFromKey(key: "notification.header.new").uppercased()
        }else {
            cell.titleLabel.text = Vocabulary.getWordFromKey(key: "notification.header.history").uppercased()
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return DeviceType.isIpad() ? 15 : 5
    }
    
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return DeviceType.isIpad() ? 15 : 5
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        GoogleAnalytics.setEvent(id: "notification_selelcted", title: "Notification Viewed")
        
        let cell = collectionView.cellForItem(at: indexPath) as! CellForNotificationDetails
        didSelectCell(cellAttibutes: cell.cellAttibutes!)
    }
    
    @objc func didSelectCell(cellAttibutes:NotiticationModel,is_new_notification:Bool = false){
        if let id = cellAttibutes.id{
            
            if !id.contains("tempId"){
                
                if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"],let hasRead = cellAttibutes.hasRead , hasRead == "false",let intId = Int(id){
                    
                    if Reachability.isAvailable(){
                        let params = ["ReadNotificationIds":[intId]]
                        ApiRequst.doRequest(requestType: .PUT, queryString: "users/\(userId)/notifications/read", parameter: params as [String : AnyObject], showHUD: false, completionHandler: { (json) in
                        })
                    }else{
                        
                        if var offlineReadNotifications = UserDefaults.standard.object(forKey: "offlineReadNotifications") as? [Int]{
                            
                            offlineReadNotifications.append(intId)
                            UserDefaults.standard.set(offlineReadNotifications, forKey: "offlineReadNotifications")
                            
                        }else{
                            UserDefaults.standard.set([intId], forKey: "offlineReadNotifications")
                        }
                    }
                    
                }
            }
            
            if #available(iOS 10.0, *) {
                
                UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { (req) in
                    
                    for notDetails in req{
                        
                        if let keyInfo = notDetails.request.content.userInfo as? [String:AnyObject]{
                            
                            if let pushId = keyInfo["aps"]?["Id"] as? Int{
                                if String(pushId) == id{
                                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notDetails.request.identifier])
                                    
                                    if req.count == 1{
                                        UIApplication.shared.applicationIconBadgeNumber = 0
                                    }
                                    
                                }
                            }
                            
                            if let value = keyInfo.values.first as? [String:AnyObject],let localId = value["id"] as? String,localId == id {
                                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notDetails.request.identifier])
                            }
                        }
                        
                    }
                    
                })
                
            }else {
                
                
            }
            
            let _ = DBManger.dbGenericQuery(queryString: "UPDATE notifications SET hasRead='\(true)' WHERE id = '\(id)'")
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            if !is_new_notification,let category = cellAttibutes.category?.lowercased(){
                if category == "local_reminder"{
                    appDelegate.showNotificationViewOnDisplay()
                }else if category == "dailymsg"{
                    if let note = cellAttibutes.note{
                        ShowAlertView.show(titleMessage: Vocabulary.getWordFromKey(key: "general.daily_msg").uppercased(), desciptionMessage: note.capitalizingFirstLetter())
                    }
                    
                }else if category == "reminder" || category == "friendrequest",let friendId = cellAttibutes.friendRequestId{
                    
                    ApiRequst.doRequest(requestType: .GET, queryString: "users/\(friendId)/userprofile", parameter: nil, completionHandler: { (userDetails) in
                        
                        if let name = userDetails["Name"] as? String{
                            DispatchQueue.main.async(execute: {
                                let alertTitle = category == "reminder" ? Vocabulary.getWordFromKey(key: "friend_request.popup.title.request_reminder").uppercased() : Vocabulary.getWordFromKey(key: "popup.title_new_friend_request").uppercased()
                                
                                CustomAlerView.delegation = self
                                CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "friend_request.popup.later").capitalized,Vocabulary.getWordFromKey(key: "friend_request.popup.title.check_profile").capitalized], titleMsg: alertTitle, desciption:  name + " " + Vocabulary.getWordFromKey(key: "friend_request.popup.desciption").lowercased(), userInfo: ["friend_request":userDetails as AnyObject])
                            })
                            
                        }
                        
                        
                    })
                    
                    
                    
                }else if let note = cellAttibutes.note{
                    
                    if let url = cellAttibutes.url,url.removeWhiteSpaces() != ""{
                        CustomAlerView.delegation = self
                        CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "general_ok").capitalized,Vocabulary.getWordFromKey(key: "popup.open_url").capitalized], titleMsg: Vocabulary.getWordFromKey(key: "dailymsg.popup.title").uppercased(), desciption: note.capitalizingFirstLetter(), userInfo: ["url":url as AnyObject])
                    }else{
                        
                        CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "general_ok").capitalized], titleMsg: Vocabulary.getWordFromKey(key: "dailymsg.popup.title").uppercased(), desciption: note.capitalizingFirstLetter(), userInfo: nil)
                    }
                    
                }
                
            }
            
            
            
            
        }
        
        self.reloadDatasources()
    }
   
    func didTappedCustomAletButton(selectedIndex:Int,title: String, userInfo: [String : AnyObject]?) {
        if selectedIndex == 1{
            
            if let info = userInfo{
                if let memberInfo = info["friend_request"] as? [String:AnyObject]{
                    let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                    if let nav = appDelegate.window?.rootViewController as? UINavigationController{
                        
                        let groupFriend = GroupFriend()
                        var nameOfUser = "Uknown"
                        if let nameOfUserValue = memberInfo["Name"] as? String,nameOfUserValue.removeWhiteSpaces().count != 0{
                            nameOfUser = nameOfUserValue
                        }
                        
                        groupFriend.name = nameOfUser
                        if let photoUrl = memberInfo["PhotoUrl"] as? String{
                            groupFriend.photoUrl = photoUrl
                        }
                        if let userId = memberInfo["UserId"] as? Int{
                            groupFriend.userId = userId
                        }
                        if let email = memberInfo["Email"] as? String{
                            groupFriend.email = email
                        }
                        if let addInfo = memberInfo["AdditionalInformation"] as? String{
                            groupFriend.additionalInfo = addInfo
                        }
                        if let userId = memberInfo["FriendStatus"] as? Int{
                             groupFriend.status = userId
                        }
                        
                        let userDetailsVC = GroupMemberDetailsView()
                        userDetailsVC.userDetails = groupFriend
                        nav.pushViewController(userDetailsVC, animated: true)
                    }
                }else if  let urlString = info["url"] as? String, let url = URL(string: urlString),UIApplication.shared.canOpenURL(url){
                    
                    UIApplication.shared.openURL(url)
                    GoogleAnalytics.setEvent(id: "open_url_from_notification", title:"URL opened from notification: \(url)")
                    
                }else{
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
                }
                
            }
           
            
            
            
            
            
        }
        
        
    }
    
}

class CellForNotificationDetails: BaseCell {
    
    var referenceOfClass:NotificationsView?
    var cellAttibutes:NotiticationModel?{
        didSet{
            labelTitle.text = "Notitification"
            labelDetails.text = "Notitcation details"
            
            if let title = cellAttibutes?.title{
                labelTitle.text = title
            }
            if let details = cellAttibutes?.note{
                labelDetails.text = details
            }
        }
    }
    
    
    let containerView:UIView={
        let view = UIView()
        view.backgroundColor = .white
        view.showShadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = DeviceType.isIpad() ? 34 : 17
        return view
    }()
    
    var labelTitle:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 17.5 : 15.5)
        label.textColor = UIColor.rgb(24, green: 16, blue: 143)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.text = "Notitification"
        
        return label
    }()
    
    var labelDetails:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 16 : 14, weight: UIFont.Weight(rawValue: -0.5))
        label.textColor = UIColor.rgb(24, green: 16, blue: 143)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = "Notitcation details"
        label.backgroundColor = .clear
        return label
    }()
    
 
    
    override func setUpCell() {
        super.setUpCell()
        self.contentView.addSubview(containerView)
        let paddingAtRightLeft:CGFloat = self.frame.width/15
        self.contentView.addConstraintsWithFormat("H:|-\(paddingAtRightLeft)-[v0]-\(paddingAtRightLeft)-|", views: containerView)
        self.contentView.addConstraintsWithFormat("V:|[v0]-5-|", views: containerView)
        
        self.containerView.addSubview(labelTitle)
        self.containerView.addSubview(labelDetails)
    
        
        
        labelTitle.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        labelDetails.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        labelTitle.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        labelDetails.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        
        self.containerView.addConstraintsWithFormat("V:|-3-[v0(v1)][v1(v0)]-3-|", views: self.labelTitle,self.labelDetails)
        
    }
    
    
    
}


class Cell_for_new_notification:CellForNotificationDetails {
    
    lazy var button_delete_notification:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "remove"), for: .normal)
        button.addTarget(self, action: #selector(self.did_select_delete_button), for: .touchUpInside)
        return button
    }()
    
    override func setUpCell() {
        self.contentView.addSubview(containerView)
        let paddingAtRightLeft:CGFloat = self.frame.width/15
        self.contentView.addConstraintsWithFormat("H:|-\(paddingAtRightLeft)-[v0]-\(paddingAtRightLeft)-|", views: containerView)
        self.contentView.addConstraintsWithFormat("V:|[v0]-5-|", views: containerView)
        
        self.containerView.addSubview(labelTitle)
        self.containerView.addSubview(labelDetails)
        self.containerView.addSubview(button_delete_notification)
        
        button_delete_notification.heightAnchor.constraint(equalToConstant: 32).isActive = true
        button_delete_notification.widthAnchor.constraint(equalToConstant: 32).isActive = true
       
        button_delete_notification.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor).isActive = true
        button_delete_notification.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).isActive = true
        
        labelTitle.rightAnchor.constraint(equalTo: button_delete_notification.leftAnchor, constant: -5).isActive = true
        labelDetails.rightAnchor.constraint(equalTo: button_delete_notification.leftAnchor, constant: -5).isActive = true
        labelTitle.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 37).isActive = true
        labelDetails.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 37).isActive = true
        
        self.containerView.addConstraintsWithFormat("V:|-3-[v0(v1)][v1(v0)]-3-|", views: self.labelTitle,self.labelDetails)
    }
    
    @objc func did_select_delete_button(){
        referenceOfClass?.didSelectCell(cellAttibutes: cellAttibutes!,is_new_notification: true)
    }
}





