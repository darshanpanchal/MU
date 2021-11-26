//
//  HomeViewController.swift
//  mindsUnlimited
//
//  Created by IPS on 30/01/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

///lightCircle
import UIKit

class HomeViewController:GeneralViewController{
    //MARK: Class properties
    
    lazy var meditateButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Vocabulary.getWordFromKey(key: "general.meditate").uppercased(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize:20, weight: UIFont.Weight.thin)
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        button.layer.cornerRadius = 20
        button.backgroundColor = .white
        button.tag = 10
        button.addTarget(self, action: #selector(self.buttonActionHandler), for: .touchUpInside)
        button.showShadow()
        return button
    }()
  
    lazy var favouriteButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.tag = 30
        button.setImage(#imageLiteral(resourceName: "fav"), for: .normal)
        button.addTarget(self, action: #selector(self.buttonActionHandler), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 10)
        return button
    }()
    
    let logoAnimationContainerView:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 0, alpha: 0)
        return view
    }()
    
    let logoLegsView:UIView={
        let view = UIView()
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.showShadow()
        return view
    }()
    
    let logoBellyView:UIView={
        let view = UIView()
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.showShadow()
        return view
    }()
    
    let logoHeadView:UIView={
        let view = UIView()
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.showShadow()
        return view
    }()
    
    let logoCircleAtHead:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.showShadow()
        return view
    }()
    
    let labelAppTitleOnLogo:UILabel={
        let lbl = UILabel()
        lbl.adjustsFontSizeToFitWidth = true
        lbl.numberOfLines = 2
        lbl.textAlignment = .center
        lbl.backgroundColor = UIColor.clear
        lbl.translatesAutoresizingMaskIntoConstraints = false
        let lbl1 = Vocabulary.getWordFromKey(key: "logo_title.minds").capitalized
        let lbl2 = Vocabulary.getWordFromKey(key: "logo_title.unlimited").uppercased()
        
        let mainString = lbl1+"\n"+lbl2
        let attributedText = NSMutableAttributedString(string:mainString)
        
        let attributesOfLbl1 = [NSAttributedStringKey.font:UIFont.systemFont(ofSize:40, weight: UIFont.Weight.light),NSAttributedStringKey.foregroundColor:UIColor.getThemeTextColor()]
        let rangeOfLbl1 = NSString(string: mainString).range(of: lbl1)
        attributedText.addAttributes(attributesOfLbl1, range: rangeOfLbl1)
        
        let attributesOfLbl2 = [NSAttributedStringKey.font:UIFont.systemFont(ofSize:27, weight: UIFont.Weight.thin),NSAttributedStringKey.foregroundColor:UIColor.getThemeTextColor()]
        let rangeOfLbl2 = NSString(string: mainString).range(of: lbl2)
        attributedText.addAttributes(attributesOfLbl2, range: rangeOfLbl2)
        
        lbl.attributedText = attributedText
        return lbl
    }()
    
    var logoCircleAtHeadYposConstaint:NSLayoutConstraint?
    
    let sizeOfHeadView:CGFloat = DeviceType.isIpad() ? 100 : 80
    let sizeOflogoCircleAtHead:CGFloat = DeviceType.isIpad() ? 30 : 25
    let gapBwTwoPart:CGFloat = DeviceType.isIpad() ? -20 : -10
    let heightOfLogoLegs:CGFloat = DeviceType.isIpad() ? 70 : 60
    //MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        InAppManager.shared.loadProducts(operation: nil)
        
        self.setUpHomeView()
        self.getDailNotificationList()
        
        if UserDefaults.standard.object(forKey: "stopLogoAnimation") != nil{
            self.setUpApplicationLogo()
            
        }else{
            self.perform(#selector(self.setUpApplicationLogo), with: nil, afterDelay: 0.7)
        }
        
        HomeViewController.sendReminderStatistics()
        self.configureNotificationView()
        
     // print(DBManger.getPath(fileName: "database.sqlite"))
        
        
        if UserDefaults.standard.object(forKey: "rate_us") == nil{
            var params = [String:Any]()
            params["IMEI"] = UIDevice.current.identifierForVendor!.uuidString
            ApiRequst.doRequest(requestType: .POST, queryString: "basedata/rate/israted", parameter: params as [String : AnyObject], completionHandler: { (response) in
                if let hasRated = response["IsRated"] as? Bool,hasRated{
                    UserDefaults.standard.set(true, forKey: "rate_us")
                }else{
                    UserDefaults.standard.set(false, forKey: "rate_us")
                }
            })
        }
        
        
    }
   
   
    //MARK: Methods
    
    func setUpHomeView(){
       
        self.backButtonOnNavigationView.isHidden = true
        self.labelTitleOnNavigation.isHidden = true
        
        self.backgroudImageView.addSubview(meditateButton)
        meditateButton.centerXAnchor.constraint(equalTo: self.backgroudImageView.centerXAnchor, constant: 0).isActive = true
        meditateButton.bottomAnchor.constraint(equalTo: self.backgroudImageView.bottomAnchor, constant: -30).isActive = true
        meditateButton.widthAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 180 : 160).isActive = true
        meditateButton.heightAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 60 : 40).isActive = true
       
        self.backgroudImageView.addSubview(favouriteButton)
        favouriteButton.bottomAnchor.constraint(equalTo: self.backgroudImageView.bottomAnchor, constant: -10).isActive = true
        favouriteButton.widthAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 80 : 60).isActive = true
        favouriteButton.heightAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 80 : 60).isActive = true
        favouriteButton.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant: 10).isActive = true
        
        let query = String.has_full_access() ? "SELECT * FROM downloadedAudios WHERE isFave = 'true' COLLATE NOCASE" : "SELECT * FROM downloadedAudios WHERE isFave = 'true' COLLATE NOCASE AND isPaid = 'false' COLLATE NOCASE"
        
        let result = DBManger.dbGenericQuery(queryString: query)
        if result.count == 0{
            favouriteButton.isHidden = true
        }else{
             favouriteButton.isHidden = false
        }
    }
    
    @objc func setUpApplicationLogo()  {
        
        self.backgroudImageView.addSubview(logoAnimationContainerView)
        logoAnimationContainerView.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant: 0).isActive = true
        logoAnimationContainerView.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant: 0).isActive = true
        logoAnimationContainerView.heightAnchor.constraint(equalToConstant:  DeviceType.isIpad() ? 450 : 350).isActive = true
        logoAnimationContainerView.centerYAnchor.constraint(equalTo: self.backgroudImageView.centerYAnchor, constant: 0).isActive = true
        
        
        self.logoAnimationContainerView.addSubview(logoLegsView)
        logoLegsView.layer.cornerRadius = (self.heightOfLogoLegs/2)
        logoLegsView.widthAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 350 : 230).isActive = true
        logoLegsView.centerXAnchor.constraint(equalTo: self.logoAnimationContainerView.centerXAnchor, constant: 0).isActive = true
        logoLegsView.bottomAnchor.constraint(equalTo: self.logoAnimationContainerView.bottomAnchor, constant: -25).isActive = true
        logoLegsView.heightAnchor.constraint(equalToConstant:heightOfLogoLegs).isActive = true
        
        self.logoAnimationContainerView.addSubview(self.logoBellyView)
        self.logoBellyView.widthAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 250 : 170).isActive = true
        self.logoBellyView.centerXAnchor.constraint(equalTo: self.logoAnimationContainerView.centerXAnchor, constant: 0).isActive = true
        self.logoBellyView.bottomAnchor.constraint(equalTo: self.logoLegsView.topAnchor, constant: gapBwTwoPart).isActive = true
        self.logoBellyView.heightAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 200 : 127).isActive = true
        self.logoBellyView.layer.cornerRadius =  DeviceType.isIpad() ? 40 : 35
        
        
        self.logoBellyView.addSubview(labelAppTitleOnLogo)
        self.logoBellyView.addConstraintsWithFormat("H:|[v0]|", views: labelAppTitleOnLogo)
        self.logoBellyView.addConstraintsWithFormat("V:|[v0]|", views: labelAppTitleOnLogo)
        
        
        self.logoAnimationContainerView.addSubview(self.logoHeadView)
        self.logoHeadView.widthAnchor.constraint(equalToConstant: self.sizeOfHeadView).isActive = true
        self.logoHeadView.centerXAnchor.constraint(equalTo: self.logoAnimationContainerView.centerXAnchor, constant: 0).isActive = true
        self.logoHeadView.bottomAnchor.constraint(equalTo: self.logoBellyView.topAnchor, constant: gapBwTwoPart).isActive = true
        self.logoHeadView.heightAnchor.constraint(equalToConstant: self.sizeOfHeadView).isActive = true
        self.logoHeadView.layer.cornerRadius = self.sizeOfHeadView/2
       
        
        
        self.logoAnimationContainerView.addSubview(self.logoCircleAtHead)
        self.logoCircleAtHead.widthAnchor.constraint(equalToConstant: self.sizeOflogoCircleAtHead).isActive = true
        self.logoCircleAtHead.heightAnchor.constraint(equalToConstant: self.sizeOflogoCircleAtHead).isActive = true
        self.logoCircleAtHead.layer.cornerRadius = self.sizeOflogoCircleAtHead/2
        self.logoCircleAtHead.centerXAnchor.constraint(equalTo: self.logoHeadView.centerXAnchor, constant: 0).isActive = true
        self.logoCircleAtHeadYposConstaint = self.logoCircleAtHead.centerYAnchor.constraint(equalTo: self.logoHeadView.centerYAnchor, constant: 0)
        self.logoAnimationContainerView.addConstraint(self.logoCircleAtHeadYposConstaint!)
        self.startAnimatinLogo()
        
    }
    
    
    func startAnimatinLogo(){
        
        if UserDefaults.standard.object(forKey: "stopLogoAnimation") != nil{
            self.logoLegsView.alpha = 1
            self.logoBellyView.alpha = 1
            self.logoHeadView.alpha = 1
            self.logoCircleAtHead.alpha = 1
            self.labelAppTitleOnLogo.alpha = 1
           logoCircleAtHeadYposConstaint?.constant = -((self.sizeOfHeadView/2)+(self.gapBwTwoPart * -1)+self.sizeOflogoCircleAtHead/2)
            return
        }else{
            UserDefaults.standard.set("stopLogoAnimation", forKey: "stopLogoAnimation")
        }
        
        logoCircleAtHeadYposConstaint?.constant = 0
        
        self.logoLegsView.alpha = 0
        self.logoBellyView.alpha = 0
        self.logoHeadView.alpha = 0
        self.logoCircleAtHead.alpha = 0
        self.labelAppTitleOnLogo.alpha = 0
        
        self.logoCircleAtHead.layer.borderColor = UIColor.white.cgColor
        self.logoCircleAtHead.layer.borderWidth = 0
        
        
        let animationDuration:TimeInterval = 2
        
        
        UIView.animate(withDuration: animationDuration, animations: {
            
            self.logoLegsView.alpha = 1
        
        }) { (comepleted) in
           
            UIView.animate(withDuration: animationDuration+0.5, animations: {
               
                self.logoBellyView.alpha = 1
           
            }, completion: { (completed) in
               
                UIView.animate(withDuration: animationDuration, animations: {
                  
                    self.logoHeadView.alpha = 0.7
                
                }, completion: {(bool) in
                    
                    self.logoCircleAtHead.alpha = 1
                    
                    self.logoCircleAtHeadYposConstaint?.constant = -((self.sizeOfHeadView/2)+(self.gapBwTwoPart * -1)+self.sizeOflogoCircleAtHead/2)
                    UIView.animate(withDuration: animationDuration,animations: {
                        self.logoHeadView.alpha = 1
                        self.logoAnimationContainerView.layoutIfNeeded()
                    }, completion: { (completed) in
                        
                        let lightCircleImageView = UIImageView()
                        lightCircleImageView.translatesAutoresizingMaskIntoConstraints = false
                        lightCircleImageView.layer.masksToBounds = true
                        lightCircleImageView.backgroundColor = .clear
                        lightCircleImageView.image = #imageLiteral(resourceName: "lightCircle")
                        lightCircleImageView.alpha = 0
                        self.logoCircleAtHead.addSubview(lightCircleImageView)
                        
                        lightCircleImageView.heightAnchor.constraint(equalToConstant: self.sizeOflogoCircleAtHead+15).isActive = true
                        lightCircleImageView.widthAnchor.constraint(equalToConstant: self.sizeOflogoCircleAtHead+15).isActive = true
                        lightCircleImageView.centerXAnchor.constraint(equalTo: self.logoCircleAtHead.centerXAnchor).isActive = true
                        lightCircleImageView.centerYAnchor.constraint(equalTo: self.logoCircleAtHead.centerYAnchor).isActive = true
                        
                        
                        
                        UIView.animate(withDuration: animationDuration, animations: {
                          
                             lightCircleImageView.alpha = 1
                            
                        }, completion: { (Bool) in
                          
                            UIView.animate(withDuration: 1, delay: 0, animations: {
                                 lightCircleImageView.alpha = 0
                                self.labelAppTitleOnLogo.alpha = 1
                                
                            }, completion: nil)
                        })
                        
                       
                    })
                })
                
              
            })
            
        }
    }
    
    @objc func buttonActionHandler(sender:UIButton){
        if sender.tag == 10 {//meditation
            GoogleAnalytics.setEvent(id: "meditation", title: "Meditation Button")
            self.goToViewController(toViewController: .meditate)
        }
        else
        {
            GoogleAnalytics.setEvent(id: "home_favourite", title: "Play Favourite Button")
            HomeViewController.playFavourite()
        }
    }
    
    func configureNotificationView(){
        
        
        if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let _ = userDetails["Id"]{
            let result = DBManger.dbGenericQuery(queryString: "SELECT * FROM notifications")
            if result.count == 0{
                NotificationsView.getNotificationFromSserver(notificationObj: nil)
            }
        }
        
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
    }

    func getDailNotificationList(){
       
        if !String.has_full_access(){
            return
        }
       
        if let lastSyncedDateAndTime = UserDefaults.standard.value(forKey: "lastSyncedDateOfDailyMessages") as? Date{
            let currentDateAndTime = Date()
            let diffTimeInterval = currentDateAndTime.timeIntervalSince(lastSyncedDateAndTime)
            let hours = (diffTimeInterval / 3600)
            
            if Int(hours) < 24{
                return
            }
        }
        
        if Reachability.isAvailable(){
          
            HomeViewController.getUpdateOfGroup(completionHandler: { (Bool) in
            })
          
            if let url = URL(string: ApiRequst.serverURL+"basedata/dailymessages"){
                URLSession.shared.dataTask(with: url, completionHandler: {
                    (data, response, error) in
                    if(error == nil){
                        do{
                            if let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [String : AnyObject]{
                                if let dailyMessages = json["DailyMessages"] as? [[String:AnyObject]],dailyMessages.count != 0{
                                    UserDefaults.standard.set(dailyMessages, forKey: "dailyMessages")
                                    UserDefaults.standard.set(Date(), forKey: "lastSyncedDateOfDailyMessages")
                                    HomeViewController.setNotificationForDailyMsg()
                                }
                            }
                        }catch{
                        }
                    }
                }).resume()
            }
        }
    }
    
    class func getUpdateOfGroup(completionHandler:@escaping (Bool)->()){
        if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"],userDetails["groupCode"] != nil{
            let queryString = "/users/\(userId)/verifymembercode"
            
            ApiRequst.doRequest(requestType: .GET, queryString: queryString, parameter: nil, showHUD: false, completionHandler: { (json) in
                
                
                if let valid = json["Valid"] as? Bool,valid{
                    userDetails["isValidGroup"] = true as AnyObject?
                }else{
                    userDetails["isValidGroup"] = false as AnyObject?
                }
               
                UserDefaults.standard.set(userDetails.nullsRemoved, forKey: "userDetails")
                completionHandler(true)
            })
        }else{
            completionHandler(true)
        }
    }
    
    
    class func setNotificationForDailyMsg(){
      
        if let preference = UserDefaults.standard.value(forKey: "reminderSettings") as? [String:AnyObject]{
            if let notificationMsg = preference["DailyMessage"]{
                if String(describing: notificationMsg).removeWhiteSpaces() == "0" || String(describing: notificationMsg).removeWhiteSpaces().lowercased() == "false"{
                    return
                }
            }
        }
        HomeViewController.removeNotificationWithKey(keyToRemove: "dailymsg")
        if let dailyMessages = UserDefaults.standard.value(forKey: "dailyMessages") as? [[String:AnyObject]],dailyMessages.count != 0{
            var msgsDictTofire = [[String:AnyObject]]()
            if dailyMessages.count > 2{
                let index1 = Int(arc4random_uniform(UInt32(dailyMessages.count)))
                let index2 = Int(arc4random_uniform(UInt32(dailyMessages.count)))
                msgsDictTofire.append(dailyMessages[index1])
                msgsDictTofire.append(dailyMessages[index2])
            }else{
                msgsDictTofire = dailyMessages
            }
            
            var messages = [String]()
            for object in msgsDictTofire{
                if let msg = object[String.getSelectedLanguage() == "1" ? "EnglishMessage" : "SwedishMessage"] as? String{
                    messages.append(msg)
                }
            }
            
            if messages.count != 0{
                
                for (index,notificationMsg) in messages.enumerated(){
                    if index < 2{
                       
                        
                        let calendar =  NSCalendar(identifier: .gregorian)!
                        let now = Date()
                        var fireComponents = calendar.components( [.year,.day,.hour,.minute], from:now)
                        fireComponents.hour = index == 1 ? 10 : 15
                        fireComponents.minute = 0
                        let localNotification = UILocalNotification()
                        let fireDate = calendar.date(from: fireComponents)
                        localNotification.fireDate =  fireDate
                        localNotification.alertBody = notificationMsg
                        localNotification.repeatInterval = .day
                        localNotification.soundName = UILocalNotificationDefaultSoundName
                        localNotification.timeZone = TimeZone.current
                        localNotification.applicationIconBadgeNumber = 1
                        let tempid = "tempId"+"".randomString(length: 10)
                        localNotification.userInfo = ["dailymsg":["id":tempid,"msg":notificationMsg.replacingOccurrences(of: "'", with: ""),"created_date":String(describing: fireDate!)]]
                        UIApplication.shared.scheduleLocalNotification(localNotification)
                  
                    }
                }
                
            }
        }
    }
    
    class func removeNotificationWithKey(keyToRemove:String){
        let app:UIApplication = UIApplication.shared
        if let sn = app.scheduledLocalNotifications{
            for notification in sn{
                if let userInfoCurrent = notification.userInfo as? [String:AnyObject]{
                    if let key = userInfoCurrent.keys.first,key.removeWhiteSpaces().lowercased() == keyToRemove.lowercased().removeWhiteSpaces(){
                        app.cancelLocalNotification(notification)
                    }
                }
            }
        }
    }
    
    class func playFavourite(){
        
        if let nv = HomeViewController.navigationObject{
            
            var downloadedAndFavAudioResultFromSqlite = DBManger.dbGenericQuery(queryString: "SELECT * FROM downloadedAudios WHERE isFave = 'true' COLLATE NOCASE")
            
            if downloadedAndFavAudioResultFromSqlite.count == 0{
                downloadedAndFavAudioResultFromSqlite = DBManger.dbGenericQuery(queryString: "SELECT * FROM downloadedAudios")
            }
            
            
            if downloadedAndFavAudioResultFromSqlite.count == 0{
                
                let meditationView = MeditationView()
                nv.pushViewController(meditationView, animated: true)
           
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "meditationview.label.download_aduo_to_play").capitalized)
                return
            }
            
            let playerView = AudioPlayerView()
            var object = [String:AnyObject]()
            if downloadedAndFavAudioResultFromSqlite.count == 1{
                object = downloadedAndFavAudioResultFromSqlite.first!
            }else{
                
                let index = Int(arc4random_uniform(UInt32(downloadedAndFavAudioResultFromSqlite.count)))
                object = downloadedAndFavAudioResultFromSqlite[index]
            }
            
            if object.keys.count == 0{
                return
            }
            let audioDetails = AudioDetails()
            if let val = object["title"] as? String{
                audioDetails.title = val
            }
            
            if let nrString = object["nr"] as? String,let langIdString = object["languageId"] as? String{
                if let intVal = Int(nrString){
                    audioDetails.nr = intVal
                }
                if let intVal = Int(langIdString){
                    audioDetails.languageId = intVal
                }
                
                let audioAttributesResultFromSqlite = DBManger.dbGenericQuery(queryString: "SELECT * FROM audioAttributes where nr = '\(nrString)' AND languageId = '\(langIdString)'")
                var audioAttributes = [AudioAttributes]()
                for (index,attObject) in audioAttributesResultFromSqlite.enumerated(){
                    let att = AudioAttributes()
                    if let val = attObject["id"] as? String,let intVal = Int(val){
                        
                        att.id = intVal
                    }
                    if let val = attObject["gender"] as? String{
                        
                        att.gender = val.replacingOccurrences(of: " ", with: "").lowercased().contains("woman") ? .woman : .man
                    }
                    if let val = attObject["fileOriginalName"] as? String{
                        
                        att.fileOriginalName = val
                    }
                    if let val = attObject["duration"] as? String{
                        
                        att.duration = val
                    }
                    if let val = attObject["fileURL"] as? String{
                        
                        att.fileURL = val
                    }
                    if let val = attObject["localPath"] as? String{
                        
                        att.localPath = val
                    }
                    if index == 0{
                        playerView.selectedFile = att
                    }
                    audioAttributes.append(att)
                    
                }
                audioDetails.files = audioAttributes
            }else{
                return
            }
            audioDetails.isFav = true
            playerView.soundDetails = audioDetails
            
            
            nv.pushViewController(playerView, animated: true)
        }
    }
    

    class func sendReminderStatistics(){
        if Reachability.isAvailable(){
            
            if let userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"],userDetails["groupCode"] != nil{
            
                
                if let reminderStatisticsOfButtons = UserDefaults.standard.object(forKey: "reminderStatisticsOfButtons") as? [[String:String]],reminderStatisticsOfButtons.count != 0{
                    
                    let params = ["data":reminderStatisticsOfButtons]
                    
                    ApiRequst.doRequest(requestType: .POST, queryString: "users/\(userId)/reminderstatistics", parameter: params as [String : AnyObject],showHUD: false, completionHandler: { (json) in
                        if json["Message"] != nil{
                            UserDefaults.standard.removeObject(forKey: "reminderStatisticsOfButtons")
                        }
                    })
                }
                
            }
            
        }
    }
    
    
    
    
    
    
}



