//
//  AppDelegate.swift
//  mindsUnlimited
//
//  Created by IPS on 30/01/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FBSDKLoginKit
import Fabric
import Crashlytics
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,customAlertDelegates {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Thread.sleep(forTimeInterval: 2)
        DBManger.initilizeDatabase()
        IQKeyboardManager.shared.enable = true
        
//        IQKeyboardManager.sharedManager().enable = true
        Fabric.with([Crashlytics.self])
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
         FirebaseApp.configure()
        FBSDKAppEvents.activateApp()
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        
        InAppManager.shared.addObjerverForPayment()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        
        if UserDefaults.standard.object(forKey: "stopLogoAnimation") != nil{
           UserDefaults.standard.removeObject(forKey: "stopLogoAnimation")
        }
        
        if UserDefaults.standard.object(forKey: "showGroupExpirePopup") != nil{
            UserDefaults.standard.removeObject(forKey: "showGroupExpirePopup")
        }
      
        let homeViewController = HomeViewController()
        let nv = UINavigationController(rootViewController: homeViewController)
        nv.isNavigationBarHidden = true
        window?.rootViewController = nv
        
        if let remoteNotif = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String:AnyObject]{
            self.takeActionOflNotification(keyInfo: remoteNotif)
        }
        
        if (launchOptions != nil) {
            
            // For local Notification
            if let localNotificationInfo = launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
                
                if let info = localNotificationInfo.userInfo as? [String:AnyObject]{
                    self.takeActionOflNotification(keyInfo: info)
                }
            } else if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as! [NSObject : AnyObject]? {
                    
                    if let info = remoteNotification as? [String:AnyObject]{
                        self.takeActionOflNotification(keyInfo: info)
                    }
            }
            
        }
        
       AppDelegate.setBadgeNumber()
        print(String.get_device_token())
        print(DBManger.getPath(fileName: "database.sqlite"))
        
       return true
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
   
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
       
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
       self.updateNotificationDataAndBadges(userInfo: nil)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
  }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        return handled
   
    }
   
    //MARK: Notification settings
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.set(token, forKey: "deviceToken")
        UserDefaults.standard.synchronize()
        
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      
        if let keyInfo = notification.request.content.userInfo as? [String:AnyObject]{
            self.takeActionOflNotification(keyInfo: keyInfo)
        }
        
    }
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        if let keyInfo = notification.userInfo as? [String:AnyObject]{
            self.takeActionOflNotification(keyInfo: keyInfo)
        }
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        if let userInfo1 = userInfo as? [String:AnyObject]{
            self.takeActionOflNotification(keyInfo: userInfo1)
        }
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        CustomAlerView.setUpPopup(buttonsName: ["OK"], titleMsg: "Failur", desciption: "Can not register the device for push notification", userInfo: nil)
    }
   
    func takeActionOflNotification(keyInfo:[String:AnyObject]){
        
       
        
        if let player = PlayAudio.player,player.isPlaying {
            self.insertNotificationInDatabase(keyInfo: keyInfo, isRead: false)
            return
        }
         self.updateNotificationDataAndBadges(userInfo: keyInfo)
         if let key = keyInfo.keys.first?.lowercased().removeWhiteSpaces(){
            if key == "reminder"{
                self.showNotificationViewOnDisplay()
            }else if (key == "dailymsg" || key == "happy_notification"){
                if let value = keyInfo.values.first as? [String:AnyObject],let msg = value["msg"] as? String{
                    
                    let vocab_key = key == "dailymsg" ? "general.daily_msg" : "dailymsg.popup.title"
                        ShowAlertView.show(titleMessage: Vocabulary.getWordFromKey(key: vocab_key).uppercased(), desciptionMessage: msg)
                }
            }else if var category = keyInfo["category"] as? String{
               
                category = category.removeWhiteSpaces().lowercased()
                if category == "reminder" || category == "friendrequest",let memberInfo =  keyInfo["memberInfo"] as? [String:AnyObject]{
                   
                    let alertTitle = category == "reminder" ? Vocabulary.getWordFromKey(key: "friend_request.popup.title.request_reminder").uppercased() : Vocabulary.getWordFromKey(key: "popup.title_new_friend_request").uppercased()
                    
                    var nameOfUser = "Uknown"
                    if let nameOfUserValue = memberInfo["Name"] as? String,nameOfUserValue.removeWhiteSpaces().count != 0{
                        nameOfUser = nameOfUserValue
                    }
                    
                    CustomAlerView.delegation = self
                    CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "friend_request.popup.later").capitalized,Vocabulary.getWordFromKey(key: "friend_request.popup.title.check_profile").capitalized], titleMsg: alertTitle, desciption:  nameOfUser + " " + Vocabulary.getWordFromKey(key: "friend_request.popup.desciption").lowercased(), userInfo: memberInfo)
                    
                }else if let message = keyInfo["aps"]?["alert"] as? String{
                    
                    if let url = keyInfo["aps"]?["url"] as? String,url.removeWhiteSpaces() != ""{
                        CustomAlerView.delegation = self
                        CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "general_ok").capitalized,Vocabulary.getWordFromKey(key: "popup.open_url").capitalized], titleMsg: Vocabulary.getWordFromKey(key: "dailymsg.popup.title").uppercased(), desciption: message.capitalizingFirstLetter(), userInfo: ["url":url as AnyObject])
                    }else{
                        
                         CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "general_ok").capitalized], titleMsg: Vocabulary.getWordFromKey(key: "dailymsg.popup.title").uppercased(), desciption: message.capitalizingFirstLetter(), userInfo: nil)
                    }
                    
                    
                    
                }
          
            }else{
            }
        }
        
    }
    func didTappedCustomAletButton(selectedIndex:Int,title: String, userInfo: [String : AnyObject]?) {
        if selectedIndex == 1{
            
            if let urlDict = userInfo{
                if  let urlString = urlDict["url"] as? String{
                    if let url = URL(string: urlString),UIApplication.shared.canOpenURL(url){
                    
                            UIApplication.shared.openURL(url)
                            GoogleAnalytics.setEvent(id: "open_url_from_notification", title:"URL opened from notification: \(url)")
                        
                    }else{
                        
                        ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
                    }
                    return
                }
            }
            
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            if let nav = appDelegate.window?.rootViewController as? UINavigationController{
                
                if let memberInfo = userInfo{
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
                    
                    groupFriend.status = 3
                    
                    let userDetailsVC = GroupMemberDetailsView()
                    userDetailsVC.userDetails = groupFriend
                    nav.pushViewController(userDetailsVC, animated: true)
                    
                }
            }
            
        }
        
      
}
    
    var containerView:UIView={
        let container = UIView()
        container.tag = 1108
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    var  btnContainerbottomAnchor:NSLayoutConstraint?
   
    func showNotificationViewOnDisplay(){
        
        if let winowObj = self.window{
            
            for subView in winowObj.subviews{
                if subView.tag == 1108{
                    subView.removeFromSuperview()
                }
            }
    
            
            var isSnoozeOn = true
            var isFiveDeppOn = true
            
            if let preference = UserDefaults.standard.value(forKey: "reminderSettings") as? [String:AnyObject]{
                
                if preference["Snooze"] != nil{
                    let snooze = String(describing: preference["Snooze"]!).lowercased().removeWhiteSpaces()
                    if (snooze == "0" || snooze == "false"){
                        isSnoozeOn = false
                    }
                }
                if preference["FiveDeepBreaths"] != nil{
                    let fiveDeepBreaths = String(describing: preference["FiveDeepBreaths"]!).lowercased().removeWhiteSpaces()
                    if (fiveDeepBreaths == "0" || fiveDeepBreaths == "false"){
                        isFiveDeppOn = false
                    }
                }
                
            }
           
            self.containerView.alpha = 1
            containerView.backgroundColor = UIColor.init(white: 0.5, alpha: 0.3)
            winowObj.addSubview(containerView)
            winowObj.addConstraintsWithFormat("H:|[v0]|", views: containerView)
            winowObj.addConstraintsWithFormat("V:|[v0]|", views: containerView)
            
            let buttonConainer:UIView={
                let container = UIView()
                container.translatesAutoresizingMaskIntoConstraints = false
                container.backgroundColor = UIColor.init(white: 0, alpha: 0)
                container.layer.cornerRadius = 3
                container.layer.masksToBounds = true
                return container
            }()
            containerView.addSubview(buttonConainer)
            containerView.addConstraintsWithFormat("H:|-5-[v0]-5-|", views: buttonConainer)
            
            var heightOfButtonContainer:CGFloat = DeviceType.isIpad() ? 300 : 170
            var fontSize:CGFloat = DeviceType.isIpad() ? 18 : 16
            if UIScreen.main.bounds.height < 481{
                heightOfButtonContainer = 145
                fontSize = 13
            }
            
            let btnContainerHeightConstraint = buttonConainer.heightAnchor.constraint(equalToConstant:heightOfButtonContainer )
            buttonConainer.addConstraint(btnContainerHeightConstraint)
          
            btnContainerbottomAnchor =  buttonConainer.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
            containerView.addConstraint(btnContainerbottomAnchor!)
            
            
            
            let buttonMeditate:UIButton={
                let btn = UIButton()
                btn.backgroundColor = .white
                btn.translatesAutoresizingMaskIntoConstraints = false
                btn.setTitle(Vocabulary.getWordFromKey(key: "general.meditate").uppercased(), for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
                btn.setTitleColor(.blue, for: .normal)
                btn.tag = 10
                btn.addTarget(self, action: #selector(buttunActionHandler), for: .touchUpInside)
                btn.layer.borderColor = UIColor.blue.cgColor
                btn.layer.cornerRadius = 16
                btn.showShadow()
                return btn
            }()
            let buttonFiveDeep:UIButton={
                let btn = UIButton()
                btn.backgroundColor = .white
                btn.translatesAutoresizingMaskIntoConstraints = false
                btn.setTitle(Vocabulary.getWordFromKey(key: "general_deep_breath").uppercased(), for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
                btn.setTitleColor(.blue, for: .normal)
                btn.tag = 20
                btn.layer.borderColor = UIColor.blue.cgColor
                btn.layer.cornerRadius = 16
                btn.showShadow()
                btn.addTarget(self, action: #selector(buttunActionHandler), for: .touchUpInside)
                return btn
            }()
            let buttonSnooze:UIButton={
                let btn = UIButton()
                btn.backgroundColor = .white
                btn.translatesAutoresizingMaskIntoConstraints = false
                btn.setTitle(Vocabulary.getWordFromKey(key: "general.snooze").uppercased(), for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
                btn.setTitleColor(.red, for: .normal)
                btn.tag = 30
                btn.layer.borderColor = UIColor.blue.cgColor
                btn.showShadow()
                btn.layer.cornerRadius = 16
                btn.addTarget(self, action: #selector(buttunActionHandler), for: .touchUpInside)
                return btn
            }()
          
            buttonConainer.addSubview(buttonMeditate)
            buttonConainer.addSubview(buttonFiveDeep)
            buttonConainer.addSubview(buttonSnooze)
            
            buttonMeditate.topAnchor.constraint(equalTo: buttonConainer.topAnchor, constant: 0).isActive = true
            let fiveDeepTopAnchor = buttonFiveDeep.topAnchor.constraint(equalTo: buttonMeditate.bottomAnchor, constant: 8)
            buttonSnooze.topAnchor.constraint(equalTo: buttonFiveDeep.bottomAnchor, constant: 8).isActive = true
            buttonConainer.addConstraint(fiveDeepTopAnchor)
            
            buttonConainer.addConstraintsWithFormat("H:|-7-[v0]-7-|", views: buttonMeditate)
            buttonConainer.addConstraintsWithFormat("H:|-7-[v0]-7-|", views: buttonFiveDeep)
            buttonConainer.addConstraintsWithFormat("H:|-7-[v0]-7-|", views: buttonSnooze)
            
            if !isFiveDeppOn && !isSnoozeOn{
                
                btnContainerHeightConstraint.constant =   btnContainerHeightConstraint.constant/3
                buttonMeditate.heightAnchor.constraint(equalTo: buttonConainer.heightAnchor, multiplier: 0.9).isActive = true
                buttonFiveDeep.heightAnchor.constraint(equalToConstant: 0).isActive = true
                buttonSnooze.heightAnchor.constraint(equalToConstant: 0).isActive = true
                buttonSnooze.alpha = 0
                buttonFiveDeep.alpha = 0
              
            }else if !isFiveDeppOn{
                
                fiveDeepTopAnchor.constant = 0
                btnContainerHeightConstraint.constant =  btnContainerHeightConstraint.constant/1.5
                buttonSnooze.heightAnchor.constraint(equalTo: buttonConainer.heightAnchor, multiplier: 0.4).isActive = true
                buttonMeditate.heightAnchor.constraint(equalTo: buttonConainer.heightAnchor, multiplier: 0.4).isActive = true
                buttonFiveDeep.heightAnchor.constraint(equalToConstant: 0).isActive = true
                buttonFiveDeep.alpha = 0
                
            }else if !isSnoozeOn{
                
                btnContainerHeightConstraint.constant =   btnContainerHeightConstraint.constant/1.5
                buttonMeditate.heightAnchor.constraint(equalTo: buttonConainer.heightAnchor, multiplier: 0.4).isActive = true
                buttonFiveDeep.heightAnchor.constraint(equalTo: buttonConainer.heightAnchor, multiplier: 0.4).isActive = true
                buttonSnooze.heightAnchor.constraint(equalToConstant: 0).isActive = true
                buttonSnooze.alpha = 0
                
            }else{
                buttonSnooze.heightAnchor.constraint(equalToConstant: (heightOfButtonContainer/3)-8).isActive = true
                buttonMeditate.heightAnchor.constraint(equalToConstant: (heightOfButtonContainer/3)-8).isActive = true
                buttonFiveDeep.heightAnchor.constraint(equalToConstant: (heightOfButtonContainer/3)-8).isActive = true
               
            }
            
            
            self.containerView.layoutIfNeeded()
            
            btnContainerbottomAnchor?.constant = -(buttonConainer.frame.height+5)
          
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.containerView.layoutIfNeeded()
            }, completion: nil)
            
        }
        
        
    }
    
    @objc func buttunActionHandler(sender:UIButton){
        self.btnContainerbottomAnchor?.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.layoutIfNeeded()
        }) { (Bool) in
            for view in self.containerView.subviews{
                view.removeFromSuperview()
            }
            self.containerView.removeFromSuperview()
            if sender.tag == 10{ // meditate
              
                GoogleAnalytics.setEvent(id: "alert_play_meditation", title:"Play Botton From  Reminder Alert")
                HomeViewController.playFavourite()
                self.sendReminderSettingsOnServer(buttonName: "meditate")
            
            }else if sender.tag == 20{
                 GoogleAnalytics.setEvent(id: "alert_five_deep_meditation", title:"Five Deep Botton From  Reminder Alert")
                self.sendReminderSettingsOnServer(buttonName: "5 deep breath")
            }else if sender.tag == 30{
                
                self.sendReminderSettingsOnServer(buttonName: "snooze")
                GoogleAnalytics.setEvent(id: "alert_snooz_meditation", title:"Snooze Botton From  Reminder Alert")
                let notification = UILocalNotification()
               
                let calendar = Calendar.current
                let fireDate = calendar.date(byAdding: .minute, value: 5, to: Date())
                notification.fireDate = fireDate
               
                let alert = Vocabulary.getWordFromKey(key: "daily_notification.popup.title")
                notification.alertBody = alert
                let tempid = "tempId"+"".randomString(length: 10)
                notification.userInfo = ["reminder":["id":tempid,"msg":alert,"created_date":String(describing:fireDate)]]
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.applicationIconBadgeNumber = 1
                UIApplication.shared.scheduleLocalNotification(notification)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "reminder.snooze_clicked").capitalizingFirstLetter())
            }
        }
    }
    
    func sendReminderSettingsOnServer(buttonName:String){
    
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = df.string(from: date)
        
        let object = ["Time":dateString,"ButtonClicked":buttonName]
        
        
        if var settings = UserDefaults.standard.object(forKey: "reminderStatisticsOfButtons") as? [[String:String]]{
            
            settings.append(object)
            UserDefaults.standard.set(settings, forKey: "reminderStatisticsOfButtons")
            
        }else{
            
            UserDefaults.standard.set([object], forKey: "reminderStatisticsOfButtons")
            
        }
       
        HomeViewController.sendReminderStatistics()
       
    }
    
    func updateNotificationDataAndBadges(userInfo:[String:AnyObject]?){
        
        if let notificationDetails = userInfo{
            self.insertNotificationInDatabase(keyInfo: notificationDetails,isRead:true) //read
        }
        if #available(iOS 10.0, *) {
            
            UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { (req) in
                
                if req.count == 0{
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.applicationIconBadgeNumber = 0 
                    })
                }
                for notDetails in req{
                 
                    if let keyInfo = notDetails.request.content.userInfo as? [String:AnyObject]{
                        
                        self.insertNotificationInDatabase(keyInfo: keyInfo,isRead:false) // unread
                     
                    }
                }
                
            })
            
        
        }else{
            
            UIApplication.shared.applicationIconBadgeNumber = 0
            
        }
        
    }
    
    func insertNotificationInDatabase(keyInfo:[String:AnyObject],isRead:Bool){
        
        if let key = keyInfo.keys.first?.lowercased().removeWhiteSpaces(), key != "reminder"{
           
            if key == "dailymsg",let value = keyInfo.values.first as? [String:AnyObject], let id = value["id"] as? String{
                
                let result = DBManger.dbGenericQuery(queryString: "SELECT * FROM notifications where id = '\(id)'")
                if result.count == 0{
                    
                    var dateToInsert = Date()
                    if var dateCreated = value["created_date"] as? String{
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
                    
                    let note = value["msg"]! as! String
                    let title =  key == "dailymsg" ? "Daily Message" : "Reminder"
                    let category =  key == "dailymsg" ? "dailymsg" : "local_reminder"
               
                    let _ = DBManger.dbGenericQuery(queryString: "INSERT INTO notifications(id,category,created_date,title,note,hasRead,is_badge_enabled) VALUES('\(id)','\(category)','\(dateToInsert)','\(title.replacingOccurrences(of: "'", with: ""))','\(note.replacingOccurrences(of: "'", with: ""))','\(isRead)','\(!isRead)')")
                    
                }else if isRead {
                    
                    let _ = DBManger.dbGenericQuery(queryString: "UPDATE notifications SET hasRead='\(true)' WHERE id = '\(id)'")
                    
                }
          
             }else if let category = keyInfo["category"] as? String,let apps = keyInfo["aps"] as? [String:AnyObject]{
                if let id = apps["Id"] as? Int{
                    let result = DBManger.dbGenericQuery(queryString: "SELECT * FROM notifications where id = '\(id)'")
                    if result.count == 0{
                        
                        var title = "Minds Unlimited"
                        if let inAppTitle = keyInfo["inAppTitle"] as? String{
                            title = inAppTitle
                        }
                        var note = "Push notification"
                        if let value = apps["alert"] as? String{
                            note = value
                        }
                        var url = ""
                        if let value = apps["url"] as? String{
                            url = value
                        }
                        var created_date = ""
                        if let value = apps["CreatedDate"] as? String{
                            created_date = value
                        }
                        
                        var dateToInsert = Date()
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd hh:mma"
                        if let tempDate = df.date(from: created_date){
                            created_date = df.string(from: tempDate)
                            
                            let df1 = DateFormatter()
                            df1.dateFormat = "MM/dd/yyy HH:mm:ss"
                            created_date = df1.string(from: tempDate)
                            if let dateToBeInserted = df1.date(from: df1.string(from: tempDate)){
                                dateToInsert = dateToBeInserted
                            }
                            
                        }
                        var friendId = "notAvailable"
                        if var memberInfo = keyInfo["memberInfo"] as? [String:AnyObject],let friendIdFromResponse = memberInfo["UserId"]{
                              friendId = String(describing: friendIdFromResponse)
                        }
                        let _ = DBManger.dbGenericQuery(queryString: "INSERT INTO notifications(id,category,created_date,title,note,hasRead,url,friend_request_id,is_badge_enabled) VALUES('\(id)','\(category)','\(dateToInsert)','\(title.replacingOccurrences(of: "'", with: ""))','\(note.replacingOccurrences(of: "'", with: ""))','\(isRead)','\(url)','\(friendId)','\(!isRead)')")
                        
                        
                    }else if isRead {
                        let _ = DBManger.dbGenericQuery(queryString: "UPDATE notifications SET hasRead='\(true)' AND is_badge_enabled='\(false)' WHERE id = '\(id)'")
                    }
                }
                
            }
            
            AppDelegate.setBadgeNumber()
        }
    }
    
    static func setBadgeNumber(){
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { (req) in
            
                if req.count > 20{
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
            })
        }
        
        let totolCountResult = DBManger.dbGenericQuery(queryString: "SELECT * FROM notifications")
        if totolCountResult.count > 20{
            let deleteCount = totolCountResult.count - 20
            let deleteQuery = "DELETE FROM notifications where serialNumber IN (SELECT serialNumber from notifications order by serialNumber ASC limit \(deleteCount))"
            _ = DBManger.dbGenericQuery(queryString: deleteQuery)
        }
    
        let result = DBManger.dbGenericQuery(queryString: "SELECT * FROM notifications where hasRead = '\(false)' AND is_badge_enabled = '\(true)'")
        DispatchQueue.main.async {
            if result.count == 0{
                GeneralViewController.labelBadge.text = "0"
                GeneralViewController.labelBadge.isHidden = true
            }else{
                GeneralViewController.labelBadge.text = String(result.count)
                GeneralViewController.labelBadge.isHidden = false
            }
        }
     }
    
    
}

