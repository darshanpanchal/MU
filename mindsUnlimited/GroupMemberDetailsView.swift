//
//  groupMemberDetailsView.swift
//  mindsUnlimited
//
//  Created by IPS on 08/03/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import Foundation
import UIKit
class GroupMemberDetailsView:GeneralViewController,UITextViewDelegate,customAlertDelegates{
  
    //MARK: Class properties 
    let fontSize = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 21 : 18)
    var userDetails:GroupFriend?
    var selectedCell:CellforGroupMemberAndFriends?
    var referenceOfGroupView:GroupsView?
    
    var profleImageView:ImageViewForURL={
        let iv = ImageViewForURL()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        iv.image = #imageLiteral(resourceName: "cell_placeholder")
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
       return iv
    }()
    
    lazy var bottomButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 22
        button.titleLabel?.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : 16)
        button.addTarget(self, action: #selector(self.handelButtonActionOfRegisterView), for: .touchUpInside)
        button.setTitle("N/A", for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    
    lazy var labelName:UILabel={
        let label = UILabel()
        label.textColor = UIColor.getThemeTextColor()
        label.font = self.fontSize
        label.textAlignment = .center
        label.text = "N/A"
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var labelEmail:UILabel={
        let label = UILabel()
        label.textColor = UIColor.getThemeTextColor()
        label.font = self.fontSize
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = "N/A"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var labelAdditionaInfo:UITextView={
        let label = UITextView()
        label.textColor = UIColor.getThemeTextColor()
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 20 : 17)
        label.textAlignment = .center
        label.text = "N/A"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.delegate = self
        return label
    }()
    
    
    //MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "title.profile").uppercased()
        self.backButtonOnNavigationView.isHidden = false
 
        self.setUpViews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        GoogleAnalytics.setScreen(name: "Group Member Details Screen", className: "GroupMemberDetailsView")
    }
    
    
    func setUpViews(){
        
        var sizeOfImageView:CGFloat = DeviceType.isIpad() ? 330 : UIScreen.main.bounds.height/3.2
        
        var spaceBetween:CGFloat = DeviceType.isIpad() ? 30 : 18
       
        if UIScreen.main.bounds.height < 481{
            sizeOfImageView = 140
            spaceBetween = 10
        }
        
        self.backgroudImageView.addSubview(profleImageView)
        self.profleImageView.heightAnchor.constraint(equalToConstant: sizeOfImageView).isActive = true
        self.profleImageView.widthAnchor.constraint(equalToConstant: sizeOfImageView).isActive = true
        self.profleImageView.centerXAnchor.constraint(equalTo: self.backgroudImageView.centerXAnchor).isActive = true
        self.profleImageView.topAnchor.constraint(equalTo: self.customNavigationImageView.bottomAnchor, constant: 20).isActive = true
        
        self.backgroudImageView.addSubview(labelName)
        self.backgroudImageView.addSubview(labelEmail)
        self.backgroudImageView.addSubview(labelAdditionaInfo)
        
        if let url = userDetails?.photoUrl{
            self.profleImageView.contentMode = .scaleToFill
            self.profleImageView.imageFromServerURL(urlString: url)
        }
        if let name = userDetails?.name{
            self.labelName.text = name.capitalized
        }
        
        if let email = userDetails?.email,email.removeWhiteSpaces().count != 0{
            self.labelEmail.text = email
            self.labelEmail.heightAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 40 : 20).isActive = true
        }else{
            self.labelEmail.text = Vocabulary.getWordFromKey(key: "groupview.member_details.label.no_email_shared")
            self.labelEmail.font = UIFont.italicSystemFont(ofSize: DeviceType.isIpad() ? 21 : 18)
             self.labelEmail.heightAnchor.constraint(equalToConstant:0).isActive = true
        }
        if let addInfo = userDetails?.additionalInfo,addInfo.removeWhiteSpaces().count != 0{
            self.labelAdditionaInfo.text = addInfo
            self.labelAdditionaInfo.heightAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 200 : 130).isActive = true
        }else{
            self.labelAdditionaInfo.text = Vocabulary.getWordFromKey(key: "groupview.label.no_additional_information")
            self.labelAdditionaInfo.font = UIFont.italicSystemFont(ofSize: DeviceType.isIpad() ? 20 : 17)
             self.labelAdditionaInfo.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
        
        
        self.labelName.topAnchor.constraint(equalTo: self.profleImageView.bottomAnchor, constant: spaceBetween).isActive = true
        self.labelName.centerXAnchor.constraint(equalTo: self.backgroudImageView.centerXAnchor).isActive = true
        self.labelName.widthAnchor.constraint(equalToConstant: self.view.frame.width-30).isActive = true
        self.labelName.heightAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 40 : 20).isActive = true
        
       
        self.labelEmail.topAnchor.constraint(equalTo: self.labelName.bottomAnchor, constant: spaceBetween).isActive = true
        self.labelEmail.centerXAnchor.constraint(equalTo: self.backgroudImageView.centerXAnchor).isActive = true
        self.labelEmail.widthAnchor.constraint(equalToConstant: self.view.frame.width-30).isActive = true
  
        
        
        self.labelAdditionaInfo.topAnchor.constraint(equalTo: self.labelEmail.bottomAnchor, constant: spaceBetween).isActive = true
        self.labelAdditionaInfo.centerXAnchor.constraint(equalTo: self.backgroudImageView.centerXAnchor).isActive = true
        self.labelAdditionaInfo.widthAnchor.constraint(equalToConstant: self.view.frame.width-30).isActive = true
       
        
      
        self.backgroudImageView.addSubview(bottomButton)
        self.bottomButton.bottomAnchor.constraint(equalTo: self.backgroudImageView.bottomAnchor, constant: -10).isActive = true
        self.bottomButton.centerXAnchor.constraint(equalTo: self.backgroudImageView.centerXAnchor).isActive = true
        if DeviceType.isIpad(){
            self.bottomButton.widthAnchor.constraint(equalToConstant: 400).isActive = true
        }else{
             self.bottomButton.widthAnchor.constraint(equalTo: self.backgroudImageView.widthAnchor, multiplier: 0.65).isActive = true
        }
        self.bottomButton.heightAnchor.constraint(equalToConstant:DeviceType.isIpad() ? 55 : 40).isActive = true
        
   
        
        if let status = userDetails?.status{
            
            self.setButtonTitleWithStatus(status: status)
            
        }else{
            self.bottomButton.isHidden = true
        }
    
    
    
    }
    
    
    func setButtonTitleWithStatus(status:Int){
        self.profleImageView.setBorder(status: status)
        var title = "N/A"
        switch status {
        case 0:
            title = Vocabulary.getWordFromKey(key: "groupview.member_details.button.send_request").uppercased()
        case 1:
            title = Vocabulary.getWordFromKey(key: "groupview.member_details.button.remove_friend").uppercased()
        case 2:
            title = Vocabulary.getWordFromKey(key: "groupview.member_details.button.send_reminder").uppercased()
        case 3:
            title = Vocabulary.getWordFromKey(key: "groupview.member_details.button.pending_request").uppercased()
        default:
            break
        }
        self.bottomButton.setTitle(title, for: .normal)
    }
    
    @objc func handelButtonActionOfRegisterView(){
        
        
        
        if let status = userDetails?.status{
            
            CustomAlerView.delegation = self
            
            if status == 1{
               
                let name = self.userDetails?.name == nil ? "" : (" \""+self.userDetails!.name!+"\" ")
                
                let desc = Vocabulary.getWordFromKey(key: "groupview.popup.sure_to_remove").capitalizingFirstLetter() + name.capitalized + Vocabulary.getWordFromKey(key: "groupview.popup.from_friend").lowercased()
                CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "general_no").uppercased(),Vocabulary.getWordFromKey(key: "general_yes").uppercased()], titleMsg: Vocabulary.getWordFromKey(key: "groupview.member_details.button.remove_friend").uppercased(), desciption:desc , userInfo: ["remove":"remove" as AnyObject])
                
           
            }
            else if status == 3{
                
                 CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "group.popup.decline").uppercased(),Vocabulary.getWordFromKey(key: "group.popup.accept").uppercased()], titleMsg: Vocabulary.getWordFromKey(key: "popup.title_new_friend_request").uppercased(), desciption: Vocabulary.getWordFromKey(key: "friend_request.popup.new_request_desciption").capitalizingFirstLetter(), userInfo: ["remove":"remove" as AnyObject])
                
            }else{
                self.updateStatusOnServer(status: status)
            }
        }
    }
    
    func didTappedCustomAletButton(selectedIndex:Int,title: String, userInfo: [String : AnyObject]?) {
        if let status = userDetails?.status{
            if selectedIndex == 1 {
                self.updateStatusOnServer(status: status)
            }else {
                if status == 3{
                    self.updateStatusOnServer(status: 4)
                }
            }
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
    
    func updateStatusOnServer(status:Int){
    
       
        if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"],let friendsId = self.userDetails?.userId{
            
            
            var querySting:String?
            var newStatus = 0
            var requestType:ApiRequst.RequestType = .POST
            switch status {
            case 0:
                querySting = "sendfriendrequest"
                GoogleAnalytics.setEvent(id: "sendfriendrequest", title: "Sent Friend Request Button")
                newStatus = 2
            case 1,4:
                querySting = status == 1 ? "removefriend" : "decline"
                GoogleAnalytics.setEvent(id: "decline_or_removefriend", title: "Decline Or remove Friend Button")
                requestType = .DELETE
                newStatus = 0
            case 2:
                querySting = "reminder"
                newStatus = status
            case 3:
                querySting = "acceptfriendrequest"
                GoogleAnalytics.setEvent(id: "acceptfriendrequest", title: "Accept Friend Request Button")
                requestType = .PUT
                newStatus = 1
            default:
                break
            }
            
            if querySting == nil{
                return
            }
            
            ApiRequst.doRequest(requestType: requestType, queryString: "users/\(userId)/friends/\(friendsId)/"+querySting!, parameter: nil) { (json) in
                if let msg = json["Message"] as? String{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: msg)
                        
                        var selectedTabOfGroupView = 0
                        let selectedIndex = self.referenceOfGroupView?.buttomMenu.collectionViewForMenu.indexPathsForSelectedItems
                        if let first = selectedIndex?.first{
                            selectedTabOfGroupView = first.item
                        }
                        
                        if status == 2{
                            self.bottomButton.isUserInteractionEnabled = false
                            self.bottomButton.backgroundColor = UIColor.init(white: 0.9, alpha: 1)
                            self.bottomButton.setTitle( Vocabulary.getWordFromKey(key: "groupview.member_details.button.title").uppercased(), for: .normal)
                        }else{
                            
                            self.setButtonTitleWithStatus(status: newStatus)
                            self.selectedCell?.imageView.setBorder(status: newStatus)
                            
                            // if friend list view then refresh needed changes
                            var currentArrayOfSelecttion = [GroupFriend]()
                            
                            if var groupMember = self.referenceOfGroupView?.groupMembers{
                                
                                for (index,member) in groupMember.enumerated(){
                                    if let memberIdInGroup = member.userId , let userId = self.userDetails?.userId,memberIdInGroup == userId{
                                        
                                        member.status = newStatus
                                        groupMember[index] = member
                                        
                                        if selectedTabOfGroupView == 0{
                                            currentArrayOfSelecttion = groupMember
                                        }
                                        
                                        
                                        self.referenceOfGroupView?.groupMembers = groupMember
                                        break
                                    }
                                }
                            }
                            
                            if var usersFrinds = self.referenceOfGroupView?.usersFrinds{
                                for (index,member) in usersFrinds.enumerated(){
                                    if let memberIdInGroup = member.userId , let userId = self.userDetails?.userId,memberIdInGroup == userId{
                                        
                                        if newStatus == 0{
                                            usersFrinds.remove(at: index)
                                        }else{
                                            member.status = newStatus
                                            usersFrinds[index] = member
                                        }
                                        if selectedTabOfGroupView == 1{
                                            currentArrayOfSelecttion = usersFrinds
                                        }
                                        self.referenceOfGroupView?.usersFrinds = usersFrinds
                                        break
                                    }
                                }
                            }
                            
                             self.referenceOfGroupView?.dataSourceForFriendsInCollectionView = currentArrayOfSelecttion
                            if newStatus == 0{
                                self.navigationController!.popViewController(animated: true)
                                return
                            }
                            
                        }
                        
                        self.userDetails?.status = newStatus
                        
                        if newStatus == 2 && selectedTabOfGroupView == 0{
                            if var userFriends = self.referenceOfGroupView?.usersFrinds{
                                userFriends.append(self.userDetails!)
                                self.referenceOfGroupView?.usersFrinds = userFriends
                            }else{
                                self.referenceOfGroupView?.usersFrinds = [self.userDetails!]
                            }
                            
                        }
                        
                    }
                }
            }
        }
    }
    
}
    
