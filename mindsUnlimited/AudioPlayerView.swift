//
//  AudioPlayerView.swift
//  mindsUnlimited
//
//  Created by IPS on 20/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//
//
import UIKit
import AVFoundation

class AudioPlayerView: GeneralViewController,AVAudioPlayerDelegate,UIGestureRecognizerDelegate {
    
     //MARK: Class properties
   
    var numberOfProgressSlicesForMusic = 48
    var numberOfProgressSlicesForReward = 24
    var classObj:AudioPlayerView?
    var soundDetails:AudioDetails?{
        didSet{
            
            if let title = soundDetails?.title{
                self.titleForSoundLabel.text = title.capitalized
            }
            if let subTitle = soundDetails?.subTitle{
                self.detailsLabel.text = subTitle.capitalized
            }
        }
    }
    
    var referenceOfMeditationView:MeditationView?
    var selectedFile:AudioAttributes?
    var timeObjervorOfAvPlayer:Timer?
    var timeLabeUpdater:Timer?
    let bottomImageForAudioInformation:UIImageView={
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    var titleForSoundLabel:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 17.5 : 15.5)
        label.textColor = UIColor.getThemeTextColor()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.text = Vocabulary.getWordFromKey(key: "general.no_details").capitalized
        return label
    }()
    var detailsLabel:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 16 : 14)
        label.textColor = UIColor.getThemeTextColor()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = Vocabulary.getWordFromKey(key: "general.no_details").capitalized
        label.backgroundColor = .clear
        return label
    }()
    lazy var favButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setImage(#imageLiteral(resourceName: "unFav"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        button.addTarget(self, action: #selector(self.makeItAsFavoutiteButtonAction), for: .touchUpInside)
        return button
    }()
    lazy var playPaushButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        button.addTarget(self, action: #selector(self.playPauseButtonAction), for: .touchUpInside)
        return button
    }()
    let progressCoantainerView:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    lazy var soundProgressImageView:UIImageView={
        let iv = UIImageView()
        iv.tag = 20
        iv.image = UIImage(named:"music_placeholder")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    lazy var circularSlider:CircularSlider={
        let circularSlider = CircularSlider()
        circularSlider.thumbLineWidth = 0
        circularSlider.backgroundColor = .clear
        circularSlider.translatesAutoresizingMaskIntoConstraints = false
        circularSlider.maximumValue = 20.225484
        circularSlider.addTarget(self, action: #selector(circularDidChangeValue), for: .valueChanged)
        circularSlider.addTarget(self, action: #selector(circulaDidEnd), for: .editingDidEnd)
        return circularSlider
    }()
    
    //MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        ShowSideMenu.showSideMenuObj.selectedCell = -1
        
        classObj = self
        
        self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "general.meditate").uppercased()
        self.view.backgroundColor = .white
        
        
        if let nrVal = soundDetails?.nr,let langId = soundDetails?.languageId{
            let result = DBManger.dbGenericQuery(queryString: "SELECT * FROM downloadedAudios where nr = '\(nrVal)' AND languageId='\(langId)' AND isFave = 'true' COLLATE NOCASE")
            if result.count != 0{
                self.favButton.setImage(#imageLiteral(resourceName: "fav"), for: .normal)
            }
        }
        self.setUpView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.playNewAudio()
        
        GoogleAnalytics.setScreen(name: "Meditations Player Screen", className: "AudioPlayerView")
        
        HomeViewController.removeNotificationWithKey(keyToRemove: "happy_notification")
        
        if String.has_full_access(){
            if let reminder_settings = UserDefaults.standard.object(forKey: "reminderSettings") as? [String:Any],let end_timing = reminder_settings["DayEnd"] as? String{
                let time_components = end_timing.components(separatedBy: ":")
                if time_components.count >= 2{
                    let hrs_string = time_components[0]
                    let min_string = time_components[1]
                    
                    if let hrs = Int(hrs_string),let mins = Int(min_string){
                        let minutes_before_meditation_ends = 10
                        if mins < minutes_before_meditation_ends{
                            self.setLocalNotfication(data: Date(), hr: hrs-1, min: (60-(minutes_before_meditation_ends-mins)))
                        }else{
                            self.setLocalNotfication(data: Date(), hr: hrs, min: mins-minutes_before_meditation_ends)
                        }
                    }
                }
            }
        }
     }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timeObjervorOfAvPlayer?.invalidate()
        self.timeLabeUpdater?.invalidate()
        PlayAudio.player = nil
    }
    
    func setUpView(){
      
        let heightOfBottomView:CGFloat = DeviceType.isIpad() ? 85 : 60
        
        self.backgroudImageView.addSubview(bottomImageForAudioInformation)
        
        self.backgroudImageView.addConstraintsWithFormat("H:|[v0]|", views: bottomImageForAudioInformation)
        self.backgroudImageView.addConstraintsWithFormat("V:[v0(\(heightOfBottomView))]|", views: bottomImageForAudioInformation)
        
        bottomImageForAudioInformation.addSubview(titleForSoundLabel)
        bottomImageForAudioInformation.addSubview(detailsLabel)
        bottomImageForAudioInformation.addSubview(favButton)
        
        let sizeOfButton:CGFloat = DeviceType.isIpad() ? 50 : 40
        
        self.favButton.leftAnchor.constraint(equalTo: bottomImageForAudioInformation.leftAnchor, constant: 10).isActive = true
        self.favButton.heightAnchor.constraint(equalToConstant: sizeOfButton).isActive = true
        self.favButton.widthAnchor.constraint(equalToConstant: sizeOfButton).isActive = true
        self.favButton.centerYAnchor.constraint(equalTo: bottomImageForAudioInformation.centerYAnchor, constant: 0).isActive = true
        
        self.titleForSoundLabel.rightAnchor.constraint(equalTo: self.bottomImageForAudioInformation.rightAnchor, constant: -sizeOfButton).isActive = true
        self.titleForSoundLabel.leftAnchor.constraint(equalTo: favButton.rightAnchor, constant: 0).isActive = true
        self.titleForSoundLabel.topAnchor.constraint(equalTo: bottomImageForAudioInformation.topAnchor, constant: 5).isActive = true
        self.titleForSoundLabel.heightAnchor.constraint(equalTo: bottomImageForAudioInformation.heightAnchor, multiplier: 0.4).isActive = true
        
        self.detailsLabel.rightAnchor.constraint(equalTo: self.bottomImageForAudioInformation.rightAnchor, constant: -sizeOfButton).isActive = true
        self.detailsLabel.leftAnchor.constraint(equalTo: favButton.rightAnchor, constant: 0).isActive = true
        self.detailsLabel.bottomAnchor.constraint(equalTo: bottomImageForAudioInformation.bottomAnchor, constant: -5).isActive = true
        self.detailsLabel.heightAnchor.constraint(equalTo: bottomImageForAudioInformation.heightAnchor, multiplier: 0.4).isActive = true
        
        
        self.backgroudImageView.addSubview(playPaushButton)
        playPaushButton.centerXAnchor.constraint(equalTo: self.backgroudImageView.centerXAnchor).isActive = true
        playPaushButton.bottomAnchor.constraint(equalTo: self.bottomImageForAudioInformation.topAnchor, constant: -25).isActive = true
        playPaushButton.heightAnchor.constraint(equalToConstant: sizeOfButton*2).isActive = true
        playPaushButton.widthAnchor.constraint(equalToConstant: sizeOfButton*2).isActive = true
        
        
        //Setup Sound pregress and reward
       
        self.backgroudImageView.addSubview(progressCoantainerView)
        let sizeOfProgressContainerView:CGFloat = self.view.frame.width/1.33
        if self.view.frame.height < 569{
            self.progressCoantainerView.bottomAnchor.constraint(equalTo: self.playPaushButton.topAnchor, constant: -20).isActive = true
        }else{
            self.progressCoantainerView.centerYAnchor.constraint(equalTo: self.backgroudImageView.centerYAnchor, constant: 0).isActive = true
        }
        self.progressCoantainerView.centerXAnchor.constraint(equalTo: self.backgroudImageView.centerXAnchor, constant: 0).isActive = true
        self.progressCoantainerView.widthAnchor.constraint(equalToConstant: sizeOfProgressContainerView).isActive = true
        self.progressCoantainerView.heightAnchor.constraint(equalToConstant: sizeOfProgressContainerView).isActive = true
   
        
        self.progressCoantainerView.addSubview(soundProgressImageView)
        self.progressCoantainerView.addConstraintsWithFormat("H:|[v0]|", views: soundProgressImageView)
        self.progressCoantainerView.addConstraintsWithFormat("V:|[v0]|", views: soundProgressImageView)
        self.progressCoantainerView.layer.cornerRadius = sizeOfProgressContainerView/2
  
       
       
        if let innerCircleStatus = UserDefaults.standard.object(forKey: "innerCircleStatus") as? [String:AnyObject]{
            if let currentProgressVal = innerCircleStatus["currentProgress"] as? Int{
                if currentProgressVal != 0{
                    self.addImageViewAsSubview(imageName: "rw"+String(currentProgressVal % numberOfProgressSlicesForReward), supperView: self.soundProgressImageView)
                }
            }
        }
        
        self.progressCoantainerView.addSubview(circularSlider)
        circularSlider.widthAnchor.constraint(equalToConstant: sizeOfProgressContainerView).isActive = true
        circularSlider.heightAnchor.constraint(equalToConstant: sizeOfProgressContainerView).isActive = true
        circularSlider.centerXAnchor.constraint(equalTo: self.progressCoantainerView.centerXAnchor, constant: 0).isActive = true
        circularSlider.centerYAnchor.constraint(equalTo: self.progressCoantainerView.centerYAnchor, constant: 0).isActive = true
      
    }
    
    //MARK: Other methods
    
    override func backButtonActionHandeler(){
        
        if let selectedIndexpath = self.referenceOfMeditationView?.languageSelectionMenu.collectionViewForMenu.indexPathsForSelectedItems?.first{
            self.referenceOfMeditationView?.willLoadDataOnCollectionView(languageId: selectedIndexpath.item == 0 ? 1 : 2)
        }else
        {
             self.referenceOfMeditationView?.willLoadDataOnCollectionView(languageId: 1)
        }
       
        self.navigationController!.popViewController(animated: true)
    }
    
    @objc func makeItAsFavoutiteButtonAction(sender:UIButton){
        GoogleAnalytics.setEvent(id: "makeItAsFavoutiteButtonAction", title: "Favourite Button")
        let currentImage = sender.image(for: .normal)
        
        if let nrVal = soundDetails?.nr,let langId = soundDetails?.languageId{
          
            var isFav = false
            if currentImage == #imageLiteral(resourceName: "unFav"){
                isFav = true
                sender.setImage(#imageLiteral(resourceName: "fav"), for: .normal)
            }else{
                sender.setImage(#imageLiteral(resourceName: "unFav"), for: .normal)
            }
            
           _ = DBManger.dbGenericQuery(queryString: "UPDATE downloadedAudios SET isFave = '\(isFav)' WHERE nr = '\(nrVal)' AND languageId='\(langId)'")
            
        }
    }
    
    @objc func playPauseButtonAction(sender:UIButton){
        
        GoogleAnalytics.setEvent(id: "playPauseButtonAction", title: "Play-Pause Button")
        
        if let playerTime = PlayAudio.player?.duration{
            if playerTime > TimeInterval(0){
                let currentImage = sender.image(for: .normal)
                if currentImage == #imageLiteral(resourceName: "play"){
                    
                    PlayAudio.player?.play()
                    self.validateAudioTimer()
                    playPaushButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                    
                    
                }else{
                    
                    sender.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                    PlayAudio.player?.pause()
                    self.timeObjervorOfAvPlayer?.invalidate()
                    self.timeLabeUpdater?.invalidate()
                }
            }
        }
    }
   
    func playNewAudio(){
        
        self.timeObjervorOfAvPlayer?.invalidate()
        self.timeLabeUpdater?.invalidate()
        if let localPath = self.selectedFile?.localPath{
            PlayAudio.player = nil
            PlayAudio.playSound(localPath: localPath)
            
            
            if let playerTime = PlayAudio.player?.duration{
                if playerTime > TimeInterval(0){
                    self.circularSlider.maximumValue = CGFloat(PlayAudio.player!.duration)
                    self.playPaushButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                    PlayAudio.player?.delegate = self
                    self.validateAudioTimer()
                }
            }
           
            
        }
    }
    
    
    @objc func updateTimeLabel(){
       
      
        if let totalDuration = selectedFile?.duration{
            
            let array = totalDuration.components(separatedBy: ":")
            if array.count == 2{
                
              
                if let min = Double(array[0]),let seconds = Double(array[1]){
                    
                    let totalSeconds = min * 60 + seconds
                    if let currentTime = PlayAudio.player?.currentTime{
                        var genderString = " - Man"
                        if let gender = selectedFile?.gender,gender == .woman{
                            genderString = " - \(Vocabulary.getWordFromKey(key: "general.woman").capitalizingFirstLetter())"
                        }
                        
                        let currentTimeInSeconds = Double(currentTime)
                        let timeToDisplay = totalSeconds - currentTimeInSeconds
                        self.detailsLabel.text = timeToDisplay.durationText + " Min" + genderString
                        
                    }
                }
                
          }
            
    }
        
        
    }
    
    func validateAudioTimer(){
        
        let totalSec = CGFloat(PlayAudio.player!.duration)
        let totalImages:CGFloat = CGFloat(numberOfProgressSlicesForMusic)
        let timeInterval = totalSec/totalImages
        self.timeObjervorOfAvPlayer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval), target: self, selector: #selector(self.audioPlayerDidProgress), userInfo: nil, repeats: true)
        self.timeLabeUpdater = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimeLabel), userInfo: nil, repeats: true)
    }
 
    var currentImageNumber = 0
    
    @objc func audioPlayerDidProgress(){
        currentImageNumber += 1
        self.addImageViewAsSubview(imageName: String(currentImageNumber), supperView: self.soundProgressImageView)
    }
    
    @objc func goBackToSoundListView(){
        
        self.timeObjervorOfAvPlayer?.invalidate()
        self.timeLabeUpdater?.invalidate()
        self.addImageViewAsSubview(imageName: String(self.numberOfProgressSlicesForMusic), supperView: self.soundProgressImageView)
        DispatchQueue.main.async {
            if let nc = self.navigationController{
                nc.popViewController(animated: true)
            }
        }
    }
    
    func addImageViewAsSubview(imageName:String,supperView:UIImageView){
     
        let tagOfImageView = (imageName.contains("rw") ? self.numberOfProgressSlicesForReward : self.numberOfProgressSlicesForMusic)
     
        for subViews in supperView.subviews{
            
            if subViews.tag == tagOfImageView{
                subViews.removeFromSuperview()
            }
        }
        
        let imageView:UIImageView={
            let iv = UIImageView()
            iv.tag = tagOfImageView
            iv.isUserInteractionEnabled = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.image = UIImage(named: imageName)
            iv.backgroundColor = .clear
            return iv
        }()
        
        supperView.addSubview(imageView)
        supperView.addConstraintsWithFormat("H:|[v0]|", views: imageView)
        supperView.addConstraintsWithFormat("V:|[v0]|", views: imageView)
        supperView.layoutIfNeeded()
    
    }

    @objc func circularDidChangeValue(){
      
        if self.circularSlider.maximumValue != 20.225484,let playerTime = PlayAudio.player?.duration{
        
            self.timeObjervorOfAvPlayer?.invalidate()
            self.timeLabeUpdater?.invalidate()
            
            let totalSec = CGFloat(playerTime)
            let totalImages:CGFloat = CGFloat(numberOfProgressSlicesForMusic)
            let seekTime = (self.circularSlider.endPointValue*totalImages)/totalSec
          /*
            if currentImageNumber > Int(seekTime){
                isFoward = false
            }else{
                isFoward = true
            }
             */
            currentImageNumber = Int(seekTime)
            self.addImageViewAsSubview(imageName: String(currentImageNumber), supperView: self.soundProgressImageView)
            
            
            
        }
    }
    //var isFoward = false
    @objc func circulaDidEnd(){
        if self.circularSlider.maximumValue != 20.225484,let _ = PlayAudio.player?.duration{
          
            PlayAudio.player?.currentTime = TimeInterval(self.circularSlider.endPointValue)
          
            if self.playPaushButton.image(for: .normal) != #imageLiteral(resourceName: "play"){
                 self.validateAudioTimer()
            }
            
           // if !isFoward{
                GoogleAnalytics.setEvent(id: "meditation_rewind", title: "Meditation Forward/Rewind")
           // }else{
           //   GoogleAnalytics.setEvent(id: "meditation_forward", title: "Meditation Forward")
           // }
        
        }
      
    }
    
    
    func informServerAboutCompletionOfMeditation(){
        
        
        guard  let soundId = self.selectedFile?.id else {
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd h:mm a "
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        let dateString = formatter.string(from: Date())
        if  Reachability.isAvailable(),let userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
            
            let params = ["MeditationId":soundId,"PlayDatetime":dateString,"Duration":""] as [String : Any]
             ApiRequst.doRequest(requestType: .POST, queryString: "users/\(userId)/statistics", parameter: params as [String : AnyObject]?, showHUD: false, completionHandler: { (json) in
                    //print(json)
             })
        
        }else{
            
            let object = ["MeditationId":soundId,"PlayDatetime":dateString,"Duration":""] as [String:Any]
            
            if var offlineStoredStatus = UserDefaults.standard.object(forKey: "unSyncedSongs") as? [[String:Any]]{
                offlineStoredStatus.append(object)
                
                UserDefaults.standard.set(offlineStoredStatus, forKey: "unSyncedSongs")
                
            }else{
                
                 UserDefaults.standard.set([object], forKey: "unSyncedSongs")
            }
        }
       
    }
    func setLocalNotfication(data:Date,hr:Int,min:Int = 0){
     
        let calendar =  NSCalendar(identifier: .gregorian)!
        let now = data
        var fireComponents = calendar.components( [[.year,.month,.day,.hour,.minute]], from:now)
        fireComponents.hour = hr
        fireComponents.minute = min
        let fireDate = calendar.date(from: fireComponents)
        
        if fireDate?.compare(data) == .orderedDescending{
            let localNotification = UILocalNotification()
            let alertBody = Vocabulary.getWordFromKey(key: "notification.happy_msg")
            localNotification.alertBody = alertBody
            localNotification.fireDate =  fireDate
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.timeZone = TimeZone.current
            localNotification.userInfo = ["happy_notification":["id":"happy_notification","msg":alertBody,"created_date":String(describing: fireDate!)]]
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
       
    
    }
    
    
    //MARK: Audio Delegate 
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        
        playPaushButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        
        
        var totalReward = 0
        var currentProgress = 0
        
        if let innerCircleStatus = UserDefaults.standard.object(forKey: "innerCircleStatus") as? [String:AnyObject]{
            if let totalRewardVal = innerCircleStatus["totalReward"] as? Int{
                totalReward = totalRewardVal % numberOfProgressSlicesForReward
            }
            if let currentProgressVal = innerCircleStatus["currentProgress"] as? Int{
                currentProgress = currentProgressVal
            }
        }
        
        
        if currentProgress == 0{
            for subView in self.soundProgressImageView.subviews{
                if subView.tag == self.numberOfProgressSlicesForMusic{
                    subView.removeFromSuperview()
                }
                
            }
        }
        
        currentProgress += 1
        
        self.addImageViewAsSubview(imageName: "rw"+String(currentProgress % self.numberOfProgressSlicesForReward), supperView: self.soundProgressImageView)
        
        if currentProgress == numberOfProgressSlicesForReward{
            
            currentProgress = 0
            totalReward += 1
            
        }
        UserDefaults.standard.set(["totalReward":totalReward,"currentProgress":currentProgress], forKey: "innerCircleStatus")
        
        self.informServerAboutCompletionOfMeditation()
        
        self.addImageViewAsSubview(imageName: "48", supperView: self.soundProgressImageView)
        
        self.perform(#selector(goBackToSoundListView), with: nil, afterDelay: 0.7)
        
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer){
        self.playPaushButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        PlayAudio.player?.pause()
        self.timeObjervorOfAvPlayer?.invalidate()
        self.timeLabeUpdater?.invalidate()
    }
    
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int){
    
    }
    
 
    
    
    
    
}

