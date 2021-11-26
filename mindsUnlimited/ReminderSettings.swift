//
//  ReminderSettings.swift
//  mindsUnlimited
//
//  Created by IPS on 08/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit
import UserNotifications

class ReminderSettings:GeneralViewController,CustomPickerViewDelegate {
    
    //MARK: Class Properties
    
    var timer:Timer?
    let waekDaysView = WeekDaysView()
    
    let viewsContainer:UIView={
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0, alpha: 0)
        return view
    }()
    
    let switchSnooze:UISwitch={
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.thumbTintColor = .white
        sw.onTintColor = UIColor.switchColor()
        sw.backgroundColor = .gray
        sw.layer.cornerRadius = 18
        sw.isOn = true
        sw.tag = 50
        sw.addTarget(self, action: #selector(switchHandler), for: .valueChanged)
        return sw
    }()
    
    let switchBreaths:UISwitch={
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.thumbTintColor = .white
        sw.onTintColor = UIColor.switchColor()
        sw.backgroundColor = .gray
        sw.layer.cornerRadius = 18
        sw.isOn = true
        sw.addTarget(self, action: #selector(switchHandler), for: .valueChanged)
        sw.tag = 60
        return sw
    }()
    
    let switchNotification:UISwitch={
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.thumbTintColor = .white
        sw.onTintColor = UIColor.switchColor()
        sw.backgroundColor = .gray
        sw.layer.cornerRadius = 18
        sw.isOn = true
        sw.tag = 511
        sw.addTarget(self, action: #selector(switchHandler), for: .valueChanged)
        return sw
    }()
    
    let fontSize = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 21 : 15.5)
    
    lazy var labelNotification:UILabel={
        let label = UILabel()
        label.textColor = UIColor.getThemeTextColor()
        label.font = self.fontSize
        label.textAlignment = .left
        label.text = Vocabulary.getWordFromKey(key: "general.daily_msg").uppercased()
        return label
    }()
    
    lazy var labelSnooze:UILabel={
        let label = UILabel()
        label.textColor = UIColor.getThemeTextColor()
        label.font = self.fontSize
        label.textAlignment = .left
        label.text = Vocabulary.getWordFromKey(key: "general.snooze").uppercased()
        return label
    }()
    
    lazy var labelDeepBreath:UILabel={
        let label = UILabel()
        label.textColor = UIColor.getThemeTextColor()
        label.font = self.fontSize
        label.textAlignment = .left
        label.text = Vocabulary.getWordFromKey(key: "general_deep_breath").uppercased()
        return label
    }()
    
    lazy var labelSessionsPerDay:UILabel={
        let label = UILabel()
        label.textColor = UIColor.getThemeTextColor()
        label.font = self.fontSize
        label.textAlignment = .left
        label.text = Vocabulary.getWordFromKey(key: "reminder_settings.session_per_day").capitalizingFirstLetter()
        return label
    }()
    
    lazy var labelSessionsPerDayValue:UILabel={
        let label = UILabel()
        label.textColor = UIColor.getThemeTextColor()
        label.font = self.fontSize
        label.textAlignment = .right
        label.text = "9"
        return label
    }()
    
    lazy var sessionSlider:SessionSlider={
        let slider = SessionSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.maximumValue = 9
        slider.tintColor = UIColor.switchColor()
        slider.thumbTintColor = .white
        slider.minimumValue = 1
        slider.value = 9
        slider.maximumTrackTintColor = .white
        slider.addTarget(self, action: #selector(self.sliderDidEndDraging), for: .touchUpInside)
        slider.addTarget(self, action: #selector(self.sliderValueIsBeingChanged), for: .valueChanged)
        return slider
    }()
    
    lazy var labelDayStart:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getThemeTextColor()
        label.font = self.fontSize
        label.textAlignment = .left
        label.text = Vocabulary.getWordFromKey(key: "reminder_settings.day_starts").uppercased()
        return label
    }()
    lazy var labelDayEnd:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getThemeTextColor()
        label.font = self.fontSize
        label.textAlignment = .left
        label.text = Vocabulary.getWordFromKey(key: "reminder_settings.label.day_ends").uppercased()
        return label
    }()
    lazy var labelDayStartValue:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getThemeTextColor()
        label.font = self.fontSize
        label.textAlignment = .center
        label.text = "09:00"
        label.tag = 10
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerForLabels))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        self.addBottomViewSeperatorOnView(view1: label)
        return label
    }()
    
    lazy var labelDayEndValue:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getThemeTextColor()
        label.font = self.fontSize
        label.textAlignment = .center
        label.text = "21:00"
        label.tag = 20
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerForLabels))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        self.addBottomViewSeperatorOnView(view1: label)
        return label
    }()
    
  
    lazy var saveButton:UIButton={
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle(Vocabulary.getWordFromKey(key: "reminder_settings.label.saving").capitalized, for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 24 : 20, weight: UIFont.Weight(rawValue: 0))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        button.contentHorizontalAlignment = .right
        button.isHidden = true
        return button
    }()
    
   
    //MARK: LifeCycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "reminder_settings.navigation.title").uppercased()
        self.setUpViews()
    }
    
    override func backButtonActionHandeler(){
        HomeViewController.setNotificationForDailyMsg()
        self.popToHomeView()
    }
    override func showSideMenu() {
        super.showSideMenu()
        HomeViewController.setNotificationForDailyMsg()
    }
    
    
    //MARK:Other methods
    func setUpViews(){
        
        let leftRightPadding:CGFloat = DeviceType.isIpad() ? 50 : 35
        
        self.backgroudImageView.addSubview(viewsContainer)
        self.backgroudImageView.addSubview(saveButton)
        self.saveButton.heightAnchor.constraint(equalToConstant:DeviceType.isIpad() ? 45 : 30).isActive = true
        self.saveButton.widthAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 130 : 100).isActive = true
        self.saveButton.bottomAnchor.constraint(equalTo: backgroudImageView.bottomAnchor, constant: -5).isActive = true
        self.saveButton.rightAnchor.constraint(equalTo: self.viewsContainer.rightAnchor, constant: 0).isActive = true
        
        self.backgroudImageView.addConstraintsWithFormat("H:|-\(leftRightPadding)-[v0]-\(leftRightPadding)-|", views: viewsContainer)
        self.viewsContainer.topAnchor.constraint(equalTo: self.customNavigationImageView.bottomAnchor, constant: 5).isActive = true
        self.viewsContainer.bottomAnchor.constraint(equalTo: self.backgroudImageView.bottomAnchor, constant: -75).isActive = true
        
        self.viewsContainer.addSubview(waekDaysView)
        waekDaysView.referenceOfReminderView = self
        self.viewsContainer.addConstraintsWithFormat("H:|[v0]|", views: waekDaysView)
        var heightOfWeakDaysView:CGFloat = DeviceType.isIpad() ? 250 : 140

        if UIScreen.main.bounds.height < 481{
            heightOfWeakDaysView = 100
        }
  
        self.viewsContainer.addConstraintsWithFormat("V:|[v0(\(heightOfWeakDaysView))]", views: waekDaysView)
        
        let switchContainer = UIView()
        switchContainer.backgroundColor = .clear
        switchContainer.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewsContainer.addSubview(switchContainer)
        self.viewsContainer.addConstraintsWithFormat("H:|[v0]|", views: switchContainer)
        switchContainer.topAnchor.constraint(equalTo: self.waekDaysView.bottomAnchor, constant: DeviceType.isIpad() ? 25 : 15).isActive = true
        switchContainer.heightAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 130 : 100).isActive = true
        switchContainer.centerXAnchor.constraint(equalTo: self.waekDaysView.centerXAnchor).isActive = true
       
        switchContainer.addSubview(labelSnooze)
        switchContainer.addSubview(switchSnooze)
        switchContainer.addConstraintsWithFormat("H:|[v0]", views: labelSnooze)
        switchContainer.addConstraintsWithFormat("V:|-4-[v0]", views: labelSnooze)
        switchContainer.addConstraintsWithFormat("H:[v0]|", views: switchSnooze)
        switchContainer.addConstraintsWithFormat("V:|[v0]", views: switchSnooze)
        
        switchContainer.addSubview(labelDeepBreath)
        switchContainer.addSubview(switchBreaths)
        switchContainer.addConstraintsWithFormat("H:|[v0]", views: labelDeepBreath)
        switchContainer.addConstraintsWithFormat("V:[v0]", views: labelDeepBreath)
        switchContainer.addConstraintsWithFormat("H:[v0]|", views: switchBreaths)
        switchContainer.addConstraintsWithFormat("V:[v0]", views: switchBreaths)
        labelDeepBreath.centerYAnchor.constraint(equalTo:switchContainer.centerYAnchor , constant: 0).isActive = true
        switchBreaths.centerYAnchor.constraint(equalTo:switchContainer.centerYAnchor , constant: 0).isActive = true
        
        switchContainer.addSubview(labelNotification)
        switchContainer.addSubview(switchNotification)
        switchContainer.addConstraintsWithFormat("H:|[v0]", views: labelNotification)
        switchContainer.addConstraintsWithFormat("V:[v0]-5-|", views: labelNotification)
        switchContainer.addConstraintsWithFormat("H:[v0]|", views: switchNotification)
        switchContainer.addConstraintsWithFormat("V:[v0]|", views: switchNotification)

        if !DeviceType.isIpad(){
            
            let sizeOfSwitch:CGFloat = 0.80
            switchBreaths.transform = CGAffineTransform(scaleX: sizeOfSwitch, y: sizeOfSwitch)
            switchSnooze.transform = CGAffineTransform(scaleX: sizeOfSwitch, y: sizeOfSwitch)
            switchNotification.transform = CGAffineTransform(scaleX: sizeOfSwitch, y: sizeOfSwitch)
        }
        
        let sliderConainder = UIView()
        sliderConainder.backgroundColor = .clear
        sliderConainder.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewsContainer.addSubview(sliderConainder)
        self.viewsContainer.addConstraintsWithFormat("H:|[v0]|", views: sliderConainder)
        sliderConainder.topAnchor.constraint(equalTo: switchContainer.bottomAnchor, constant: DeviceType.isIpad() ? 45 : 30).isActive = true
        sliderConainder.heightAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 100 : 65).isActive = true
        sliderConainder.centerXAnchor.constraint(equalTo: self.waekDaysView.centerXAnchor).isActive = true
        
        sliderConainder.addSubview(labelSessionsPerDay)
        sliderConainder.addSubview(labelSessionsPerDayValue)
        sliderConainder.addConstraintsWithFormat("H:|[v0][v1(50)]-13-|", views: labelSessionsPerDay,labelSessionsPerDayValue)
        sliderConainder.addConstraintsWithFormat("V:|[v0]", views: labelSessionsPerDay)
        sliderConainder.addConstraintsWithFormat("V:|[v0]", views: labelSessionsPerDayValue)
     
        sliderConainder.addSubview(sessionSlider)
        sliderConainder.addConstraintsWithFormat("H:|[v0]|", views: self.sessionSlider)
        sliderConainder.addConstraintsWithFormat("V:[v0]|", views: self.sessionSlider)
        
        let dayStartEndContainer = UIView()
        dayStartEndContainer.backgroundColor = .clear
        dayStartEndContainer.translatesAutoresizingMaskIntoConstraints = false
       
        self.viewsContainer.addSubview(dayStartEndContainer)
        self.viewsContainer.addConstraintsWithFormat("H:|[v0]|", views: dayStartEndContainer)
        dayStartEndContainer.topAnchor.constraint(equalTo: sliderConainder.bottomAnchor, constant: DeviceType.isIpad() ? 20 : (UIScreen.main.bounds.height < 481 ? 5 : 12)).isActive = true
        
        var heightOfDaysLabel:CGFloat =  DeviceType.isIpad() ? 130 : 80
        if UIScreen.main.bounds.height < 481{
            heightOfDaysLabel = 80
        }
        
        dayStartEndContainer.heightAnchor.constraint(equalToConstant: heightOfDaysLabel).isActive = true
        dayStartEndContainer.centerXAnchor.constraint(equalTo: self.waekDaysView.centerXAnchor).isActive = true
        
        dayStartEndContainer.addSubview(self.labelDayStart)
        dayStartEndContainer.addSubview(self.labelDayEnd)
        dayStartEndContainer.addSubview(self.labelDayStartValue)
        dayStartEndContainer.addSubview(self.labelDayEndValue)
        
        let widthOfValueLabel:CGFloat = DeviceType.isIpad() ? 180 : 120
        
        if UIScreen.main.bounds.height < 481{
            
            self.labelDayStart.textAlignment = .center
            self.labelDayEnd.textAlignment = .center
            
            self.labelDayStart.topAnchor.constraint(equalTo: dayStartEndContainer.topAnchor, constant: 0).isActive = true
            self.labelDayStart.leftAnchor.constraint(equalTo: dayStartEndContainer.leftAnchor, constant: 0).isActive = true
            self.labelDayStart.widthAnchor.constraint(equalToConstant: widthOfValueLabel).isActive = true
            
            self.labelDayEnd.topAnchor.constraint(equalTo: dayStartEndContainer.topAnchor, constant: 0).isActive = true
            self.labelDayEnd.rightAnchor.constraint(equalTo: dayStartEndContainer.rightAnchor, constant: 0).isActive = true
            self.labelDayEnd.widthAnchor.constraint(equalToConstant: widthOfValueLabel).isActive = true
            
            self.labelDayStartValue.topAnchor.constraint(equalTo: self.labelDayStart.bottomAnchor, constant: 5).isActive = true
            self.labelDayStartValue.leftAnchor.constraint(equalTo: dayStartEndContainer.leftAnchor, constant: 0).isActive = true
            self.labelDayStartValue.widthAnchor.constraint(equalToConstant: widthOfValueLabel).isActive = true
            self.labelDayStartValue.heightAnchor.constraint(equalTo: dayStartEndContainer.heightAnchor, multiplier: 0.4).isActive = true
            
            self.labelDayEndValue.topAnchor.constraint(equalTo: self.labelDayEnd.bottomAnchor, constant: 5).isActive = true
            self.labelDayEndValue.rightAnchor.constraint(equalTo: dayStartEndContainer.rightAnchor, constant: 0).isActive = true
            self.labelDayEndValue.widthAnchor.constraint(equalToConstant: widthOfValueLabel).isActive = true
            self.labelDayEndValue.heightAnchor.constraint(equalTo: dayStartEndContainer.heightAnchor, multiplier: 0.4).isActive = true
        }else{
            
            dayStartEndContainer.addConstraintsWithFormat("H:|[v0][v1(\(widthOfValueLabel))]|", views: self.labelDayStart,self.labelDayStartValue)
            dayStartEndContainer.addConstraintsWithFormat("H:|[v0][v1(\(widthOfValueLabel))]|", views: self.labelDayEnd,self.labelDayEndValue)
            dayStartEndContainer.addConstraintsWithFormat("V:|[v0(v1)]-\(DeviceType.isIpad() ? 10 : 5)-[v1(v0)]|", views: self.labelDayStart,self.labelDayEnd)
            dayStartEndContainer.addConstraintsWithFormat("V:|[v0(v1)]-\(DeviceType.isIpad() ? 10 : 5)-[v1(v0)]|", views: self.labelDayStartValue,self.labelDayEndValue)
            
        }
        
        self.getReminderPreferenceFromServer()
        
    }
    
    
    func addBottomViewSeperatorOnView(view1:UIView){
        let languageMenuSeperator1:UIView={
            let view = UIView()
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.4
            view.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
            view.layer.shadowRadius = 0.7
            view.layer.masksToBounds = false
            view.backgroundColor = .white
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        view1.addSubview(languageMenuSeperator1)
        view1.addConstraintsWithFormat("H:|-4-[v0]-4-|", views: languageMenuSeperator1)
        view1.addConstraintsWithFormat("V:[v0(1.5)]-2-|", views: languageMenuSeperator1)
    }
    
    @objc func sliderValueIsBeingChanged(sender:UISlider){
         labelSessionsPerDayValue.text = String(Int(sender.value))
    }
    @objc func sliderDidEndDraging(){
        self.setReminderPreferenceOnServer()
        GoogleAnalytics.setEvent(id: "slider_menu", title: "slider for daily notitfication : count \(self.sessionSlider.value)")
    }
    
    var selectedLabelForDay = 0
    @objc func tapGestureRecognizerForLabels(sender:UITapGestureRecognizer){
        var selelctedHr = "09"
        var selelctedMin = "00"
        
        var seperatedComponent = [String]()
        if sender.view?.tag == 10{
            selectedLabelForDay = 10
            seperatedComponent = self.labelDayStartValue.text!.components(separatedBy: ":")
        }else{
             selectedLabelForDay = 20
            seperatedComponent = self.labelDayEndValue.text!.components(separatedBy: ":")
        }
        if seperatedComponent.count == 2{
            selelctedHr = seperatedComponent[0]
            selelctedMin = seperatedComponent[1]
        }
    
        var component1 = [String]()
        var component2 = [String]()
        for i in 1..<25{
            var string1 = String(i)
            if string1.count == 1{
                string1 = "0"+string1
            }
            component1.append(string1)
        }
        for i in 0..<60{
            var string1 = String(i)
            if string1.count == 1{
                string1 = "0"+string1
            }
            component2.append(string1)
        }
        ShowPickerView.showPickerView(dataSouceForComponent1: component1, selectedValueForComponent1: selelctedHr, dataSouceForComponent2: component2, selectedValueForComponent2: selelctedMin)
        ShowPickerView.pickerViewObj.delegation = self
    }
 
    func didSelectWeekDay(selectedArr:[[String:String]]){
        self.setReminderPreferenceOnServer()
    }
    
    func didTappedDoneButton(selectedValueForComponent1: String, selectedValueForComponent2: String, index1: Int, index2: Int) {
        
        var statingMins:Double = 0
        var endingMins:Double = 0
        
        if selectedLabelForDay == 10{ //start
            
         
            
            if let hr = Double(selectedValueForComponent1),let min = Double(selectedValueForComponent2){
                statingMins = hr*60 + min
            }
            
            let array  = self.labelDayEndValue.text!.components(separatedBy: ":")
            if array.count == 2{
                if let hr = Double(array[0]),let min = Double(array[1]){
                    endingMins = hr*60 + min
                }
            }
            
            if endingMins < statingMins{
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "reminder_settings.daystart_smaller"))
                return
            }
          
            self.labelDayStartValue.text = selectedValueForComponent1+":"+selectedValueForComponent2
            
            
        }else if selectedLabelForDay == 20{
            
            
            if let hr = Double(selectedValueForComponent1),let min = Double(selectedValueForComponent2){
                endingMins = hr*60 + min
            }
            
            let array  = self.labelDayStartValue.text!.components(separatedBy: ":")
            if array.count == 2{
                if let hr = Double(array[0]),let min = Double(array[1]){
                    statingMins = hr*60 + min
                }
            }
            if endingMins < statingMins{
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "reminder_settings.daystart_smaller"))
                return
            }
            self.labelDayEndValue.text = selectedValueForComponent1+":"+selectedValueForComponent2
        }
        
        self.setReminderPreferenceOnServer()
        
       
    }
    
    @objc func switchHandler(sender:UISwitch){
        if sender.tag == 511{
            GoogleAnalytics.setEvent(id: "daily_notification_switch", title: "Daily Notification \(sender.isOn)")
            self.perform(#selector(self.setDailyNotificationPreference), with: nil, afterDelay: 1)
        }else if sender.tag == 50{
            GoogleAnalytics.setEvent(id: "snooze_switch", title: "snooze \(sender.isOn)")
        }else if sender.tag == 60{
            GoogleAnalytics.setEvent(id: "breath_switch", title: "breath \(sender.isOn)")
        }
        self.setReminderPreferenceOnServer(isSwitch: true)
    }
    
    @objc func setDailyNotificationPreference(){
        
        let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background)
        backgroundQueue.async {
            if self.switchNotification.isOn {
                HomeViewController.setNotificationForDailyMsg()
            }else{
                HomeViewController.removeNotificationWithKey(keyToRemove: "dailymsg")
            }
        }
       
    }
    
    func setReminderPreferenceOnServer(isSwitch:Bool = false){
        var params = [String:AnyObject]()
        var daysTosent = [String]()
        let daysArr = waekDaysView.daysNames
        for object in daysArr{
            if let isActive = object.values.first,let nameOfDay = object.keys.first{
                if isActive.removeWhiteSpaces() == "1"{
                    daysTosent.append(nameOfDay.capitalized)
                }
            }
        }
        params["Days"] = daysTosent as AnyObject?
        params["Snooze"] = String(self.switchSnooze.isOn) as AnyObject?
        params["DailyMessage"] =  String(self.switchNotification.isOn) as AnyObject?
        params["FiveDeepBreaths"] = String(self.switchBreaths.isOn) as AnyObject?
        params["SessionisPerDay"] = self.labelSessionsPerDayValue.text as AnyObject?
        params["DayStart"] = self.labelDayStartValue.text as AnyObject?
        params["DayEnd"] = self.labelDayEndValue.text as AnyObject?
       
        
        var tobeSave  = params
        tobeSave["Days"] = waekDaysView.daysNames as AnyObject?
      
        GoogleAnalytics.setEvent(id: "selelected_days", title:"selected days \(daysTosent)")
        GoogleAnalytics.setEvent(id: "start_time", title: "Start Time: \(self.labelDayStart.text!)")
        GoogleAnalytics.setEvent(id: "end_time", title: "End Time: \(self.labelDayEndValue.text!)")
        
        UserDefaults.standard.set(tobeSave.nullsRemoved, forKey: "reminderSettings")
        if !isSwitch{
            
            let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background)
            backgroundQueue.async {
                 self.setNotificationSettings(configData: tobeSave)
            }
            
        }
        
        func setTimer(){
            if #available(iOS 10.0, *) {
                timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: { (Timer) in
                    DispatchQueue.main.async(execute: {
                        self.saveButton.isHidden = true
                    })
                })
            } else {
                 self.saveButton.isHidden = true
                // Fallback on earlier versions
            }
        }
        if timer != nil{
            self.saveButton.isHidden = false
            timer?.invalidate()
            setTimer()
            
        }else{
              setTimer()
        }
        
       
        
        if Reachability.isAvailable(){
            if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
                let queryString = "/users/\(userId)/ReminderSettings"
                ApiRequst.doRequest(requestType: .POST, queryString: queryString, parameter: params, showHUD: false, completionHandler: { (json) in
                    
                })
                
            }
        }
    }
  
    
    func getReminderPreferenceFromServer(){
        func set(){
            if let preference = UserDefaults.standard.value(forKey: "reminderSettings") as? [String:AnyObject]{
                if let days = preference["Days"] as? [[String:String]]{
                   self.waekDaysView.daysNames = days
                }
                if let snooze = preference["Snooze"]{
                    if String(describing: snooze).removeWhiteSpaces() == "1" || String(describing: snooze).removeWhiteSpaces().lowercased() == "true"{
                         self.switchSnooze.isOn = true
                    }else{
                         self.switchSnooze.isOn = false
                    }
                   
                }
                if let fiveDeepBreaths = preference["FiveDeepBreaths"]{
                    if String(describing: fiveDeepBreaths).removeWhiteSpaces() == "1" || String(describing: fiveDeepBreaths).removeWhiteSpaces().lowercased() == "true"{
                        self.switchBreaths.isOn = true
                    }else{
                        self.switchBreaths.isOn = false
                    }
               }
                
                if let notificationMsg = preference["DailyMessage"]{
                    if String(describing: notificationMsg).removeWhiteSpaces() == "1" || String(describing: notificationMsg).removeWhiteSpaces().lowercased() == "true"{
                        self.switchNotification.isOn = true
                    }else{
                        self.switchNotification.isOn = false
                    }
                }
                
                if let sessionisPerDay = preference["SessionisPerDay"]{
                    self.labelSessionsPerDayValue.text = String(describing: sessionisPerDay)
                    if let floatVal = Float(String(describing: sessionisPerDay)){
                        self.sessionSlider.value = floatVal
                    }
                }
                if let dayStart = preference["DayStart"] as? String{
                    self.labelDayStartValue.text = dayStart
                }
                if let dayEnd = preference["DayEnd"] as? String{
                    self.labelDayEndValue.text = dayEnd
                }
                
                self.setReminderPreferenceOnServer()
            }
        }
        
        if Reachability.isAvailable(){
            
            if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
                let queryString = "/users/\(userId)/ReminderSettings"
                ApiRequst.doRequest(requestType: .GET, queryString: queryString, parameter: nil, showHUD: true, completionHandler: { (json) in
                   if var preference = json["ReminderSettings"] as? [String:AnyObject]{
                    
                        if let days = preference["Days"] as? [String]{
                            var object = [[String:String]]()
                            let daysArray = ["MON","TUE","WED","THU","FRI","SAT","SUN","ALL"]
                            
                            for day in daysArray{
                            
                                var isSelected = "0"
                                
                                if days.contains(day.capitalized){
                                    isSelected = "1"
                                }
                                object.append([day.uppercased():isSelected])
                            }
                            preference["Days"] = object as AnyObject?
                        }
                        
                        UserDefaults.standard.set(preference.nullsRemoved, forKey: "reminderSettings")
                    }
                    
                    DispatchQueue.main.async(execute: {
                         set()
                    })
                })
                
            }else{
                set()
            }
            
        }else{
            set()
        }
    }
    
    func setNotificationSettings(configData:[String:AnyObject]){
        
      //  let calendar =  NSCalendar(identifier: .gregorian)!
        func setUpLocalNotification(hour: Int, minute: Int,dayToSet:Int) {
            

            let calender = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
            
            let dateComp: NSDateComponents?
            let components: NSDateComponents = NSDateComponents()
            
            components.setValue(0, forComponent: .year)
            let previousDate =  NSCalendar.current.date(byAdding: components as DateComponents, to: NSDate() as Date)
            dateComp = calender?.components([.year,.weekOfMonth,.month], from: previousDate!) as NSDateComponents?
            dateComp?.hour = hour
            dateComp?.minute = minute
            dateComp?.weekday = dayToSet
            
            let notification = UILocalNotification()
            notification.repeatInterval = NSCalendar.Unit.weekOfYear
            notification.repeatCalendar = calender as Calendar?
            let fireDate = calender?.date(from: dateComp! as DateComponents)
            notification.fireDate = fireDate
            let alert = Vocabulary.getWordFromKey(key: "daily_notification.popup.title")
            notification.alertBody = alert
            let tempid = "tempId"+"".randomString(length: 10)
            notification.userInfo = ["reminder":["id":tempid,"msg":alert,"created_date":String(describing: fireDate!)]]
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.applicationIconBadgeNumber = 1
            UIApplication.shared.scheduleLocalNotification(notification)
            
        }
        
        UIApplication.shared.cancelAllLocalNotifications()
        
        if let dayStart = configData["DayStart"] as? String,let dayEnd = configData["DayEnd"] as? String,let days = configData["Days"] as? [[String:String]]{
            
            if days.count != 0{
                
                var weekdays = [Int]()
                for day in days{
                    if let isActive = day.values.first,isActive.lowercased().removeWhiteSpaces() == "1"{
                        if let dayName = day.keys.first{
                            switch dayName.lowercased().removeWhiteSpaces() {
                            case "mon":
                                weekdays.append(2)
                            case "tue":
                                weekdays.append(3)
                            case "wed":
                                weekdays.append(4)
                            case "thu":
                                weekdays.append(5)
                            case "fri":
                                weekdays.append(6)
                            case "sat":
                                weekdays.append(7)
                            case "sun":
                                weekdays.append(1)
                            case "all":
                                weekdays = [1,2,3,4,5,6,7]
                            default:
                                break
                            }
                        }
                    }
                }
                
                var startingMin:Double = 0
                var endingMin:Double = 0
                let array1  = dayStart.components(separatedBy: ":")
                if array1.count == 2{
                    if let hr = Double(array1[0]),let min = Double(array1[1]){
                        startingMin = hr*60 + min
                    }
                }
                let array2  = dayEnd.components(separatedBy: ":")
                if array2.count == 2{
                    if let hr = Double(array2[0]),let min = Double(array2[1]){
                        endingMin = hr*60 + min
                    }
                }
                
                let totalWorkingMinutes = endingMin - startingMin
                
                
                if let sessionDay = configData["SessionisPerDay"] as? String,let sessionDayIntValue = Double(sessionDay){
                    
                    let timeIntervalForNotification = totalWorkingMinutes/sessionDayIntValue
                    
                    for dayToSet in weekdays{
                        
                        for counter in 1..<(Int(sessionDayIntValue)+1){
                            
                            let notificationTimeInMinutes = (startingMin+(timeIntervalForNotification*Double(counter)))
                            let hr = Int(notificationTimeInMinutes/60)
                            let min = Int(notificationTimeInMinutes) % 60
                            setUpLocalNotification(hour: hr, minute: min,dayToSet:dayToSet)
                            
                        }
                    }
                    
                }
                
            }
        }
        
    }
    
    
}
class SessionSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height:8))
    }
}


