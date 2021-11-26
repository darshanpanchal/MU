//
//  GroupsView.swift
//  mindsUnlimited
//
//  Created by IPS on 08/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit

class GroupsView:GeneralViewController,MenuItemDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,customAlertDelegates {
    //MARK: Class properties
    enum GroupViewType {
        case notGroupCode
        case notProfileImage
        case joined
        case loading
    }
    let groupJoinedId = "groupJoinedId"
    let groupNotJoinedId = "groupNotJoinedId"
    let usersFiendsId = "usersFiendsId"
    lazy var collectionViewForGroup:UICollectionView={
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        cv.backgroundColor = .clear
        cv.register(CellForShowingGroupJoined.self, forCellWithReuseIdentifier:self.groupJoinedId)
        cv.register(CellForShowingNoGroupJoined.self, forCellWithReuseIdentifier:self.groupNotJoinedId)
        cv.register(CellForShowingUsersFriends.self, forCellWithReuseIdentifier:self.usersFiendsId)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        return cv
    }()
    
    let buttomMenu = MenuItemsCollection()
    var currentViewType:GroupViewType = .loading
    
    var usersFrinds:[GroupFriend]?
    var groupMembers:[GroupFriend]?
    var dataSourceForFriendsInCollectionView:[GroupFriend]?{
        didSet{
            self.collectionViewForGroup.reloadData()
        }
    }
    
    
    lazy var joinGroupTextField:CustomTextField={
        let txt = CustomTextField()
        txt.translatesAutoresizingMaskIntoConstraints = false
        txt.placeholder = Vocabulary.getWordFromKey(key: "groupview.textfiled.placeholder.enter_code").uppercased()
        txt.textAlignment = .left
        txt.layer.masksToBounds = true
        txt.textColor = UIColor.getThemeTextColor()
        txt.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 17 : 15)
        txt.returnKeyType = .default
        return txt
    }()
    
    lazy var labelInvalidGroup:UILabel={
        let label = UILabel()
        label.text =  Vocabulary.getWordFromKey(key: "groupview.label.group_expired").uppercased()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getThemeTextColor()
        label.font =  UIFont.systemFont(ofSize: DeviceType.isIpad() ? 20: 18)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var isValidGroup = false
    
    var heightOfInavalidGroupLabel:NSLayoutConstraint?
    
    
    //MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.setUpViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentViewType == .notProfileImage{
            self.doGroupAndProfileImageValidation()
        }
       
        
    }
 
 
    //MARK: Collection view Delegates

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.width, height:collectionView.frame.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        if indexPath.item == 0{
            if currentViewType == .joined{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.groupJoinedId, for: indexPath) as! CellForShowingGroupJoined
                cell.referenceOfGroupView = self
                cell.friendsArray = self.dataSourceForFriendsInCollectionView
                return cell
            }else{
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.groupNotJoinedId, for: indexPath) as! CellForShowingNoGroupJoined
                
                self.heightOfInavalidGroupLabel?.constant = 0
                 cell.referenceOfGroupView = self
                
                cell.joinGroupButton.isHidden = false
                cell.labelGroupNotJoined.isHidden = false
                if currentViewType == .notGroupCode{
                    cell.joinGroupButton.setTitle(Vocabulary.getWordFromKey(key: "meditationview.label.join_group").uppercased(), for: .normal)
                    cell.labelGroupNotJoined.text =  Vocabulary.getWordFromKey(key: "groupview.label.no_group_joined").uppercased()
                }else if currentViewType == .notProfileImage{
                    cell.joinGroupButton.setTitle(Vocabulary.getWordFromKey(key: "groupview.label.set_image").uppercased(), for: .normal)
                    cell.labelGroupNotJoined.text = Vocabulary.getWordFromKey(key: "groupview.image_needed_for_group").uppercased()
                }else{
                    cell.joinGroupButton.isHidden = true
                    cell.labelGroupNotJoined.isHidden = true
                }
                return cell
                
            }
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.usersFiendsId, for: indexPath) as! CellForShowingUsersFriends
            cell.referenceOfGroupView = self
            cell.friendsArray = self.dataSourceForFriendsInCollectionView
            return cell
        }
   
    }
   
    //MARK: Other methods
    func setUpViews(){
       
        
        let rightLeftPadding:CGFloat = DeviceType.isIpad() ? 55 : 35
        
        
        self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "general_group").uppercased()
       
        self.backgroudImageView.addSubview(self.buttomMenu)
        self.buttomMenu.typeOfMenu = .language
        self.buttomMenu.delegate = self
        let heigtOfBottomMenu:CGFloat = DeviceType.isIpad() ? 65 : 40
        
        self.backgroudImageView.addConstraintsWithFormat("H:|-32-[v0]-32-|", views: self.buttomMenu)
       
        self.buttomMenu.bottomAnchor.constraint(equalTo: self.backgroudImageView.bottomAnchor, constant: 2).isActive = true
        self.buttomMenu.heightAnchor.constraint(equalToConstant: heigtOfBottomMenu).isActive = true
        
        
        
        let group = DataSourceForMenuCollection()
        group.uniqueId = "group"
        group.titleForCell = Vocabulary.getWordFromKey(key: "general_group").uppercased()
        
        let friends = DataSourceForMenuCollection()
        friends.uniqueId = "friends"
        friends.titleForCell = Vocabulary.getWordFromKey(key: "general_friends").uppercased()
        
        self.buttomMenu.menuDataSource = [group,friends]
        
        self.backgroudImageView.addSubview(collectionViewForGroup)
        self.backgroudImageView.addSubview(self.labelInvalidGroup)
        
        self.backgroudImageView.addConstraintsWithFormat("H:|-\(rightLeftPadding)-[v0]-\(rightLeftPadding-3)-|", views: collectionViewForGroup)
        self.backgroudImageView.addConstraintsWithFormat("H:|-[v0]-|", views: self.labelInvalidGroup)
        self.labelInvalidGroup.topAnchor.constraint(equalTo: self.customNavigationImageView.bottomAnchor, constant: 0).isActive = true
        self.heightOfInavalidGroupLabel = self.labelInvalidGroup.heightAnchor.constraint(equalToConstant: 50)
        self.backgroudImageView.addConstraint(self.heightOfInavalidGroupLabel!)
        
        
        self.collectionViewForGroup.topAnchor.constraint(equalTo: self.labelInvalidGroup.bottomAnchor, constant: 0).isActive = true
        self.collectionViewForGroup.bottomAnchor.constraint(equalTo: self.buttomMenu.topAnchor, constant: -7).isActive = true
       
        self.getUserFriendsOrGroupMembers(isGroupMemberCall: false)
       
        MeditationView.setUpSeperatorOnLanguageMenu(languageSelectionMenu: buttomMenu)
      
        MeditationView.languageMenuSeperator2.isHidden = true
        MeditationView.languageMenuSeperator1.isHidden = false
        
 
    }
    
    func doGroupAndProfileImageValidation(){
     
        if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
            
             if userDetails["profileImageViewData"] == nil{
                
                let queryString = "/users/\(userId)/profiledetail"
                ApiRequst.doRequest(requestType: .GET, queryString: queryString, parameter: nil, completionHandler: { (json) in
                    
                    if let userProfile = json["UserProfile"] as? [String:AnyObject]{
                        
                        if let addtionalInfo = userProfile["AdditionalInformation"] as? String{
                            userDetails["AdditionalInformation"] = addtionalInfo as AnyObject?
                        }
                        if let name = userProfile["Name"] as? String{
                            userDetails["Name"] = name as AnyObject?
                        }
                        if let showEmail = userProfile["ShowEmail"]{
                            userDetails["ShowEmail"] = String(describing: showEmail) as AnyObject?
                        }
                      
                        userDetails["profileImageViewData"] = nil
                        if let photoUrl = userProfile["PhotoUrl"] as? String,photoUrl.removeWhiteSpaces().count != 0{
                            userDetails["profileImageViewData"] = photoUrl as AnyObject?
                            UserDefaults.standard.set(userDetails.nullsRemoved, forKey: "userDetails")
                            DispatchQueue.main.async {
                                self.doGroupAndProfileImageValidation()
                            }
                        }else{
                            self.currentViewType = .notProfileImage
                            UserDefaults.standard.set(userDetails.nullsRemoved, forKey: "userDetails")
                            DispatchQueue.main.async {
                                self.collectionViewForGroup.reloadData()
                            }
                        }
                    }
                })
             }else if userDetails["groupCode"] == nil{
                
                self.currentViewType = .notGroupCode
                self.collectionViewForGroup.reloadData()
           
             }else {
                
              self.veriflyGroupId()
            }
            
        }
    }
    
   
    override func backButtonActionHandeler(){
        self.popToHomeView()
    }
    
    @objc func handleButtonAction(sender:UIButton){
        if sender.tag == 10{
            if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject]{
                if userDetails["profileImageViewData"] == nil{
                  
                    self.goToViewController(toViewController: .profile, backToParentWhenDone: true)
                }else{
                    
                    self.joinGroupWithCode()
                    
                }
            }
            
        }else if sender.tag == 20{ // leave group
        
            GoogleAnalytics.setEvent(id: "leave_group", title: "Leave Group Button")
            CustomAlerView.delegation = self
            CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "general_no").uppercased(),Vocabulary.getWordFromKey(key: "general_yes").uppercased()], titleMsg: Vocabulary.getWordFromKey(key: "groupview.general.leave_group").uppercased(), desciption: Vocabulary.getWordFromKey(key: "groupview.popup.leave_group_desc").capitalizingFirstLetter(), userInfo: nil)
            
        }else if sender.tag == 30{ // change
            GoogleAnalytics.setEvent(id: "change_group", title: "Change Group Button")
            self.joinGroupWithCode(changeGroups: true)
        }else if sender.tag == 50 || sender.tag == 51{
            
            
            self.view.endEditing(true)
            joinGroupContainer.removeFromSuperview()
            CustomAlerView.buttonPressed(sender: sender)
            
            if sender.tag == 51{
                if joinGroupTextField.text?.removeWhiteSpaces().count != 0
                {
                    if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
                        let queryString = "/users/\(userId)/membercodes/\(joinGroupTextField.text!)"
                        ApiRequst.doRequest(requestType: .POST, queryString: queryString, parameter: nil, completionHandler: { (json) in
                            
                            DispatchQueue.main.async(execute: {
                              if let msg = json["Message"] as? String{
                                    
                                    ShowToast.show(toatMessage: msg)
                                }
                                if let memberCode = json["MemberCodeId"] as? Int {
                                    userDetails["groupCode"] = self.joinGroupTextField.text! as AnyObject?
                                    userDetails["memberCodeId"] = String(memberCode) as AnyObject?
                                    UserDefaults.standard.set(userDetails.nullsRemoved, forKey: "userDetails")
                                    self.groupMembers = nil
                                    self.doGroupAndProfileImageValidation()
                                }
                                
                            })
                        })
                    }
                    
                }else{
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "groupview.enter_group_code"))
                }
            }
        }
    }
    
    func veriflyGroupId() {
        
        
        if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
             let queryString = "/users/\(userId)/verifymembercode"
            ApiRequst.doRequest(requestType: .GET, queryString: queryString, parameter: nil, completionHandler: { (json) in
                
                DispatchQueue.main.sync {
                    
                    if let valid = json["Valid"] as? Bool,valid{
                        
                    
                        self.setGroupNameOnHeader(isInvalid: true)
                        userDetails["isValidGroup"] = true as AnyObject?
                     
                    }else{
                        
                        
                        if let isDeleted = json["IsDeleted"] {
                            let deletedValue = String(describing: isDeleted)
                            if deletedValue.removeWhiteSpaces() == "1" || deletedValue.removeWhiteSpaces() == "true"{
                              
                           
                                
                                if let title = json["DeleteTitle"] as? String,let details = json["DeleteDescription"] as? String{
                                    
                                    CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "general_ok").capitalized], titleMsg: title.capitalizingFirstLetter(), desciption: details, userInfo: nil)
                                }else{
                                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "groupview.group_code_invalid"))
                                }
                                self.currentViewType = .notGroupCode
                                self.collectionViewForGroup.reloadData()
                                
                                
                                userDetails.removeValue(forKey: "groupCode")
                                userDetails.removeValue(forKey: "memberCodeId")
                                UserDefaults.standard.set(userDetails.nullsRemoved, forKey: "userDetails")
                                return
                            }
                        }
                        
                        
                        
                        self.setGroupNameOnHeader(isInvalid: false)
                        userDetails["isValidGroup"] = false as AnyObject?
                        
                        
                        if !String.has_valid_in_app_purchase(){
                            if UserDefaults.standard.object(forKey: "showGroupExpirePopup") == nil{
                                
                                UserDefaults.standard.set("showGroupExpirePopup", forKey: "showGroupExpirePopup")
                                CustomAlerView.delegation = self
                                CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "friend_request.popup.later").capitalizingFirstLetter(),Vocabulary.getWordFromKey(key: "groupview.popup.get_subcription").capitalizingFirstLetter()], titleMsg: Vocabulary.getWordFromKey(key: "groupview.popup.group_expired_title").uppercased(), desciption: Vocabulary.getWordFromKey(key: "groupview.popup.group_expired_desc"), userInfo: ["subscribe":"subscribe" as AnyObject])
                            }
                         
                        }else{
                            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "groupview.group_code_invalid"))
                        }
                    }
                    self.currentViewType = .joined
                    self.getUserFriendsOrGroupMembers(isGroupMemberCall: true)
                    UserDefaults.standard.set(userDetails.nullsRemoved, forKey: "userDetails")
                    
                }
            })
        }
        
    }
    
    func didTappedCustomAletButton(selectedIndex:Int,title: String, userInfo: [String : AnyObject]?) {
        if selectedIndex == 1{
            if let userInformation = userInfo,userInformation["subscribe"] != nil{
                InAppManager.shared.loadProducts(operation: .buy)
                return
            }
            
            if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
                
                let queryString = "/users/\(userId)/membercodes"
                ApiRequst.doRequest(requestType: .DELETE, queryString: queryString, parameter: nil, completionHandler: { (json) in
                    print(json)
                    
                    
                    DispatchQueue.main.async(execute: {
                        
                        userDetails.removeValue(forKey: "groupCode")
                        userDetails.removeValue(forKey: "memberCodeId")
                        UserDefaults.standard.set(userDetails.nullsRemoved, forKey: "userDetails")
                        
                        if let msg = json["Message"] as? String{
                            ShowToast.show(toatMessage: msg)
                        }
                        self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "general_group").uppercased()
                        self.isValidGroup = false
                        self.currentViewType = .notGroupCode
                        self.collectionViewForGroup.reloadData()
                        
                        
                    })
                    
                })
            }
        }
    }
    
    let joinGroupContainer = UIView()
    func joinGroupWithCode(changeGroups:Bool = false){
        
        let titleKey = changeGroups ? "groupview.button.change_group" : "meditationview.label.join_group"
        
        CustomAlerView.labelHeaderTitle.text = Vocabulary.getWordFromKey(key: titleKey).uppercased()
        CustomAlerView.labelDescrption.text = Vocabulary.getWordFromKey(key: "groupview.enter_group_code")
        
        
        
        joinGroupContainer.backgroundColor = UIColor.init(white: 0, alpha: 0)
        self.view.addSubview(joinGroupContainer)
        self.view.addConstraintsWithFormat("H:|[v0]|", views:joinGroupContainer)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: joinGroupContainer)
        
        self.joinGroupTextField.text = ""
        let widthOfPopupView = DeviceType.isIpad() ? 320 : 270
        let heightOfPopView = DeviceType.isIpad() ? 240 : 220
        
        let sizeOfHeaderView:CGFloat = CGFloat(widthOfPopupView/5)
        
        let bottomPadding:CGFloat = DeviceType.isIpad() ? 15 : 10
        let heightOfButton:CGFloat = DeviceType.isIpad() ? 40 : 30
        let gapBwTwoButtons:CGFloat = DeviceType.isIpad() ? 10 : 7
        
        
        joinGroupContainer.addSubview(CustomAlerView.backgroundView)
        joinGroupContainer.addConstraintsWithFormat("H:|[v0]|", views: CustomAlerView.backgroundView)
        joinGroupContainer.addConstraintsWithFormat("V:|[v0]|", views: CustomAlerView.backgroundView)
        
        CustomAlerView.backgroundView.addSubview(CustomAlerView.alertViewContainer)
        
        let extraHeight = 20
        
        CustomAlerView.backgroundView.addConstraintsWithFormat("H:[v0(\(widthOfPopupView+extraHeight))]", views: CustomAlerView.alertViewContainer)
        CustomAlerView.backgroundView.addConstraintsWithFormat("V:[v0(\(heightOfPopView))]", views: CustomAlerView.alertViewContainer)
        
        CustomAlerView.alertViewContainer.centerYAnchor.constraint(equalTo: CustomAlerView.backgroundView.centerYAnchor).isActive = true
        CustomAlerView.alertViewContainer.centerXAnchor.constraint(equalTo: CustomAlerView.backgroundView.centerXAnchor).isActive = true
        
        CustomAlerView.alertViewContainer.addSubview(CustomAlerView.backgroudImageView)
        CustomAlerView.alertViewContainer.addConstraintsWithFormat("H:|[v0]|", views: CustomAlerView.backgroudImageView)
        CustomAlerView.alertViewContainer.addConstraintsWithFormat("V:|[v0]|", views: CustomAlerView.backgroudImageView)
        
        CustomAlerView.backgroudImageView.addSubview(CustomAlerView.labelHeaderTitle)
        CustomAlerView.backgroudImageView.addSubview(CustomAlerView.labelDescrption)
        CustomAlerView.backgroudImageView.addSubview(self.joinGroupTextField)
        
        CustomAlerView.backgroudImageView.addConstraintsWithFormat("H:|-5-[v0]-5-|", views: CustomAlerView.labelHeaderTitle)
        CustomAlerView.backgroudImageView.addConstraintsWithFormat("H:|-15-[v0]-15-|", views: CustomAlerView.labelDescrption)
        CustomAlerView.backgroudImageView.addConstraintsWithFormat("H:|-15-[v0]-15-|", views: self.joinGroupTextField)
       
        CustomAlerView.labelDescrption.isUserInteractionEnabled = false
        
        CustomAlerView.backgroudImageView.addConstraintsWithFormat("V:|[v0(\(sizeOfHeaderView))][v1(70)]-12-[v2(30)]", views: CustomAlerView.labelHeaderTitle,CustomAlerView.labelDescrption,self.joinGroupTextField)
        
        var buttonArray = [UIButton]()
        var viewDict = [String:AnyObject]()
        let buttonsName = [Vocabulary.getWordFromKey(key: "general.cancel").capitalized,Vocabulary.getWordFromKey(key: "groupview.join").capitalized]
        for (index,title) in buttonsName.enumerated(){
            
            let btn = UIButton()
            btn.tag = 50+index
            btn.setTitle(title.uppercased(), for: .normal)
            btn.backgroundColor = .white
            btn.showShadow()
            btn.titleLabel?.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 16 : 14)
            btn.layer.cornerRadius = 16
            btn.titleLabel?.adjustsFontSizeToFitWidth = true
            btn.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
            btn.addTarget(self, action: #selector(handleButtonAction), for: .touchUpInside)
            buttonArray.append(btn)
        }
        
        var horizontalString = "H:|"
        for (index,button) in buttonArray.enumerated(){
            
            CustomAlerView.backgroudImageView.addSubview(button)
            CustomAlerView.backgroudImageView.addConstraintsWithFormat("V:[v0(\(heightOfButton))]-\(bottomPadding)-|", views:button)
            if index == 0{
                let size = "v"+String(buttonArray.count == 1 ? 0 : 1)
                horizontalString += "-\(gapBwTwoButtons)-[v\(index)(\(size))]-\(gapBwTwoButtons)-"
            }else{
                let size = "v"+String(buttonArray.count-1 == index ? 0 : index+1)
                horizontalString += "[v\(index)(\(size))]-\(gapBwTwoButtons)-"
            }
            viewDict["v\(index)"] = button
            
        }
        horizontalString += "|"
        CustomAlerView.backgroudImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: horizontalString, options: NSLayoutFormatOptions(), metrics: nil, views: viewDict))
      
    }
    func didSelectItemAtIndexPath(selectedCellInfo: DataSourceForMenuCollection) {
        
        let selectedIndex = self.buttomMenu.collectionViewForMenu.indexPathsForSelectedItems
        if let first = selectedIndex?.first{
          
            self.collectionViewForGroup.selectItem(at: first, animated: true, scrollPosition: .left)
            self.dataSourceForFriendsInCollectionView = first.item == 0 ? self.groupMembers : self.usersFrinds
            
            var groupTitle = ""
            if isValidGroup{
                groupTitle = Vocabulary.getWordFromKey(key: "groupview.title.premium").uppercased()+" "+Vocabulary.getWordFromKey(key: "general_group").uppercased()
                
            }else{
                 groupTitle = Vocabulary.getWordFromKey(key: "general_group").uppercased()
            }
            
            self.labelTitleOnNavigation.text = first.item == 0 ? groupTitle : Vocabulary.getWordFromKey(key: "general_friends").uppercased()
            
            GoogleAnalytics.setEvent(id: "botton_tab", title: "Group-Friends Tab")
            
        }
    }
    
    
    func getUserFriendsOrGroupMembers(isGroupMemberCall:Bool){
        
        
        
        if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
            
            
            let groupId = userDetails["memberCodeId"] != nil ? String(describing: userDetails["memberCodeId"]!) : ""
            let queryString = "/users/\(userId)/\(isGroupMemberCall ? "/membercodes/\(groupId)/userprofiles" : "friends")"
            
            ApiRequst.doRequest(requestType: .GET, queryString: queryString, parameter: nil, completionHandler: { (json) in
                
                DispatchQueue.main.sync {
                    
                    
                    var tempFriendsHolder = [GroupFriend]()
                    
                    let key = isGroupMemberCall ? "UserProfiles" : "Friends"
                    
                    if let friends = json[key] as? [[String:AnyObject]]{
                        
                        for object in friends{
                            let friend = GroupFriend()
                            if let userId = object["UserId"] as? Int{
                                friend.userId = userId
                            }
                            if let name = object["Name"] as? String{
                                friend.name = name
                            }
                            if let email = object["Email"] as? String{
                                friend.email = email
                            }
                            if let additionalInformation = object["AdditionalInformation"] as? String{
                                friend.additionalInfo = additionalInformation
                            }
                            if let photoUrl = object["PhotoUrl"] as? String,photoUrl.removeWhiteSpaces().count != 0{
                                
                                friend.photoUrl = photoUrl
                            }
                            if let friendStatus = object["FriendStatus"] as? Int{
                                friend.status = friendStatus
                            }
                            tempFriendsHolder.append(friend)
                        }
                        
                    }
                    
                    if isGroupMemberCall{
                         self.groupMembers = tempFriendsHolder
                        
                        self.dataSourceForFriendsInCollectionView = self.groupMembers
                        
                        DispatchQueue.main.async {
                            self.collectionViewForGroup.reloadData()
                        }
                        
                    }else{
                        self.usersFrinds = tempFriendsHolder
                        DispatchQueue.main.async {
                             self.doGroupAndProfileImageValidation()
                        }
                    }
                }
                
            })
            
            
        }
        
    }
    
   
  
    func setGroupNameOnHeader(isInvalid:Bool){
        
        labelInvalidGroup.text = "N/A"
        if let userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject],let groupCode = userDetails["groupCode"] as? String{
            
            labelInvalidGroup.text = groupCode
        }
        labelInvalidGroup.textColor = UIColor.getYellowishColor()
        labelInvalidGroup.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 22: 20)
        heightOfInavalidGroupLabel?.constant = 50
        if isInvalid{
            isValidGroup = true
            self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "groupview.title.premium").uppercased()+" "+Vocabulary.getWordFromKey(key: "general_group").uppercased()
            
        }else{
              isValidGroup = false
              self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "general_group").uppercased()
        }
        
    }

    
   
}


class CellForShowingNoGroupJoined:BaseCell{
    
    var referenceOfGroupView:GroupsView?
    lazy var joinGroupButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        button.backgroundColor = .white
        button.setTitle(Vocabulary.getWordFromKey(key: "meditationview.label.join_group").uppercased(), for: .normal)
        button.tag = 10
        button.layer.cornerRadius = 22
        button.titleLabel?.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : 16)
        button.addTarget(self, action: #selector(self.handelButtonAction), for: .touchUpInside)
        return button
    }()
    
    let labelGroupNotJoined:UILabel={
        let label = UILabel()
        label.text =  Vocabulary.getWordFromKey(key: "groupview.label.no_group_joined").uppercased()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getThemeTextColor()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : 16)
        return label
    }()
    
    override func setUpCell() {
        
        self.addSubview(labelGroupNotJoined)
        self.addSubview(joinGroupButton)
        
        self.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: labelGroupNotJoined)
        labelGroupNotJoined.topAnchor.constraint(equalTo: self.topAnchor, constant: 30).isActive = true
        labelGroupNotJoined.heightAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 75 : 65).isActive = true
        
        let paddingForiPhone:CGFloat = Int(UIScreen.main.bounds.width) > 320 ? 40 : 15
        let padding:CGFloat =  DeviceType.isIpad() ? 100 : paddingForiPhone
        let heightOfButton:CGFloat = DeviceType.isIpad() ? 50 : 40
        
        joinGroupButton.topAnchor.constraint(equalTo: self.labelGroupNotJoined.bottomAnchor, constant: DeviceType.isIpad() ? 55 : 40).isActive = true
        joinGroupButton.heightAnchor.constraint(equalToConstant: heightOfButton).isActive = true
        joinGroupButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -padding).isActive = true
        joinGroupButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant:padding).isActive = true
        
    }
    
    
    @objc func handelButtonAction(){
        if referenceOfGroupView != nil{
            referenceOfGroupView!.handleButtonAction(sender: joinGroupButton)
        }
    }
    
    
}

class CellForShowingGroupJoined:BaseCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    var referenceOfGroupView:GroupsView?
    var bottomAnchorOfCollectionView:NSLayoutConstraint?
    var friendsArray:[GroupFriend]?{
        didSet{
            collectionView.reloadData()
        }
    }
    let cellId = "cellId4"
    lazy var collectionView:UICollectionView={
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        cv.backgroundColor = .clear
        cv.register(CellforGroupMemberAndFriends.self, forCellWithReuseIdentifier:self.cellId)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = UIEdgeInsetsMake(0, 0, 70, 0)
        return cv
    }()
    
    lazy var leaveGroupButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        button.backgroundColor = .white
        button.setTitle(Vocabulary.getWordFromKey(key: "groupview.general.leave_group").uppercased(), for: .normal)
        button.tag = 20
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 14 : 12)
        button.addTarget(self, action: #selector(self.handelButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var changeGroupButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        button.backgroundColor = .white
        button.setTitle(Vocabulary.getWordFromKey(key: "groupview.button.change_group").uppercased(), for: .normal)
        button.tag = 30
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 14 : 12)
        button.addTarget(self, action: #selector(self.handelButtonAction), for: .touchUpInside)
        return button
    }()
    
    let leaveChangeButtonContainer:UIView={
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
   
    lazy var colorIndicatorView:UIView={
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        let labelFiendColorIndicator = self.getColorLabel(labelType: 0)
        let labelPendingFiendColorIndicator = self.getColorLabel(labelType: 1)
        let labelNotFiendColorIndicator = self.getColorLabel(labelType: 2)
        
        view.addSubview(labelFiendColorIndicator)
        view.addSubview(labelPendingFiendColorIndicator)
        view.addSubview(labelNotFiendColorIndicator)
        
        view.addConstraintsWithFormat("H:|-1-[v0(v1)]-1-[v1(v0)]-1-[v2(v0)]-1-|", views: labelFiendColorIndicator,labelPendingFiendColorIndicator,labelNotFiendColorIndicator)
        view.addConstraintsWithFormat("V:[v0(15)]|", views: labelFiendColorIndicator)
        view.addConstraintsWithFormat("V:[v0(15)]|", views: labelPendingFiendColorIndicator)
        view.addConstraintsWithFormat("V:[v0(15)]|", views: labelNotFiendColorIndicator)
        
        
        let viewFiendColorIndicator = self.getColorBox(labelType: 0)
        let viewPendingFiendColorIndicator = self.getColorBox(labelType: 1)
        let viewNotFiendColorIndicator = self.getColorBox(labelType: 2)
        
        view.addSubview(viewFiendColorIndicator)
        view.addSubview(viewPendingFiendColorIndicator)
        view.addSubview(viewNotFiendColorIndicator)
        
        let boxSize:CGFloat = 25
        
        view.addConstraintsWithFormat("V:[v0(\(boxSize))]", views: viewFiendColorIndicator)
        view.addConstraintsWithFormat("V:[v0(\(boxSize))]", views: viewPendingFiendColorIndicator)
        view.addConstraintsWithFormat("V:[v0(\(boxSize))]", views: viewNotFiendColorIndicator)
        view.addConstraintsWithFormat("H:[v0(\(boxSize))]", views: viewFiendColorIndicator)
        view.addConstraintsWithFormat("H:[v0(\(boxSize))]", views: viewPendingFiendColorIndicator)
        view.addConstraintsWithFormat("H:[v0(\(boxSize))]", views: viewNotFiendColorIndicator)
        
        
        viewFiendColorIndicator.centerXAnchor.constraint(equalTo:labelFiendColorIndicator.centerXAnchor).isActive = true
        viewPendingFiendColorIndicator.centerXAnchor.constraint(equalTo: labelPendingFiendColorIndicator.centerXAnchor).isActive = true
        viewNotFiendColorIndicator.centerXAnchor.constraint(equalTo: labelNotFiendColorIndicator.centerXAnchor).isActive = true
        
        viewFiendColorIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        viewPendingFiendColorIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        viewNotFiendColorIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
        return view
    }()
    
    
    
    override func setUpCell() {
  
        self.addSubview(leaveChangeButtonContainer)
        
        self.leaveChangeButtonContainer.addSubview(colorIndicatorView)
        
        let hightOfleaveChangeView:CGFloat = DeviceType.isIpad() ? 130 : 100
        let hightOfleaveChangeButton:CGFloat = DeviceType.isIpad() ? 50 : 30
        
        leaveChangeButtonContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        leaveChangeButtonContainer.heightAnchor.constraint(equalToConstant: hightOfleaveChangeView).isActive = true
        leaveChangeButtonContainer.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        leaveChangeButtonContainer.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        
        
        leaveChangeButtonContainer.addSubview(leaveGroupButton)
        leaveChangeButtonContainer.addSubview(changeGroupButton)
        
        leaveChangeButtonContainer.addConstraintsWithFormat("V:[v0(\(hightOfleaveChangeButton))]|", views: leaveGroupButton)
        leaveChangeButtonContainer.addConstraintsWithFormat("V:[v0(\(hightOfleaveChangeButton))]|", views: changeGroupButton)
        
        leaveChangeButtonContainer.addConstraintsWithFormat("H:|-10-[v0(v1)]-20-[v1(v0)]-10-|", views: leaveGroupButton,changeGroupButton)
        leaveChangeButtonContainer.addConstraintsWithFormat("V:|[v0]-\(hightOfleaveChangeButton+10)-|", views: colorIndicatorView)
        leaveChangeButtonContainer.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: colorIndicatorView)
        
        self.addSubview(collectionView)
        self.addConstraintsWithFormat("H:|-25-[v0]-25-|", views: collectionView)
        
        collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        
        bottomAnchorOfCollectionView = collectionView.bottomAnchor.constraint(equalTo: leaveChangeButtonContainer.bottomAnchor, constant:-(hightOfleaveChangeButton+(hightOfleaveChangeButton/2)))
       
        self.addConstraint(bottomAnchorOfCollectionView!)
        
        self.bringSubview(toFront: leaveChangeButtonContainer)
      
    }
    @objc func handelButtonAction(sender:UIButton){
        if referenceOfGroupView != nil{
            referenceOfGroupView!.handleButtonAction(sender: sender)
        }
    }
    
    
    //MARK: Collection view Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
         collectionView.removeNoDataLabel()
        
        if let count = friendsArray?.count,count != 0{
            return count
        }
       
        let selectedIndex = referenceOfGroupView?.buttomMenu.collectionViewForMenu.indexPathsForSelectedItems
        if let first = selectedIndex?.first{
            collectionView.showNoDataFound(msg: Vocabulary.getWordFromKey(key: first.item == 0 ? "groupview.label.no_user_in_group" : "groupview.label.no_friend_added"))
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CellforGroupMemberAndFriends
        cell.referenceOfCollectionView = collectionView
        cell.memberDetails = friendsArray![indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let size:CGFloat = (self.collectionView.frame.width/2)-20
        
        return CGSize(width: size, height:size)
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let friend = friendsArray?[indexPath.item]
        
        let gmv = GroupMemberDetailsView()
        let cell = collectionView.cellForItem(at: indexPath) as! CellforGroupMemberAndFriends
        gmv.selectedCell = cell
        gmv.userDetails = friend
        gmv.referenceOfGroupView = self.referenceOfGroupView
        
        if let nv = self.referenceOfGroupView?.navigationController{
            nv.pushViewController(gmv, animated: true)
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    
    
    func getColorLabel(labelType:Int)->UILabel{
        let label = UILabel()
        if labelType == 2{
            label.text =  Vocabulary.getWordFromKey(key: "group_view.color_title.not_friend").uppercased()
        }else if labelType == 1{
             label.text =  Vocabulary.getWordFromKey(key: "group_view.color_title.pending_friend").uppercased()
        }else{
             label.text =  Vocabulary.getWordFromKey(key: "group_view.color_title.friend").uppercased()
        }
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getYellowishColor()
        label.font =  UIFont.systemFont(ofSize: DeviceType.isIpad() ? 14: 9)
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    
    
    func getColorBox(labelType:Int)->UIView{
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        if labelType == 2{
            view.setBorder(status: 0)
        }else if labelType == 1{
            view.setBorder(status: 2)
        }else{
            view.setBorder(status: 1)
        }
        view.layer.cornerRadius = 6.5
        return view
   
    }
    
    
}

class CellForShowingUsersFriends:CellForShowingGroupJoined{
   
    override func setUpCell() {
        super.setUpCell()
        
        self.leaveChangeButtonContainer.isHidden = true
        self.bottomAnchorOfCollectionView?.constant = 0
    }
    
}


class CellforGroupMemberAndFriends:BaseCell{
    
    var referenceOfCollectionView:UICollectionView?
    var memberDetails:GroupFriend?{
        didSet{
            
           imageView.image = #imageLiteral(resourceName: "cell_placeholder")
            if let url = memberDetails?.photoUrl{
                imageView.imageFromServerURL(urlString: url)
                imageView.contentMode = .scaleAspectFill
            }
            
            if let name = memberDetails?.name{
                labelName.text = name
            }
            
            if let status = memberDetails?.status{
              /*  0 - No Friend
                1 - Friend
                2 - Request Sent
                3 - Pending Approve*/
               imageView.setBorder(status: status)
            }
        }
    }
    
    let imageView:ImageViewForURL={
        let iv = ImageViewForURL()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let labelName:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18: 12)
        label.textColor = UIColor.getThemeTextColor()
        label.text = "N/A"
        return label
    }()
    
    override func setUpCell() {
        
        self.addSubview(imageView)
        self.addSubview(labelName)
        
        imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.85).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.85).isActive = true
        
        self.addConstraintsWithFormat("H:|[v0]|", views: labelName)
        labelName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5).isActive = true
  
    }
}


