//
//  LanguageView.swift
//  mindsUnlimited
//
//  Created by IPS on 08/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit

class LanguageView: GeneralViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    //MARK:  Class proprties
    
    var languagesSource:[Language]?{
        didSet{
            collectionViewForLanguages.reloadData()
        }
    }
    
    
    let languageMenuSeperator2:UIView={
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 0.7
        view.layer.masksToBounds = false
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let reUsableId = "cellId"
    
    lazy var collectionViewForLanguages:UICollectionView={
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        
        cv.register(CellForLanguage.self, forCellWithReuseIdentifier:self.reUsableId)
     
        
        return cv
    }()
    
    var selectedCell = 0
    
    //MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "title.language").uppercased()
        
        self.setUpViews()
    }
    
    //MARK: CollectionView Delegates
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.languagesSource?.count{
            return count
        }
        
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reUsableId, for: indexPath) as! CellForLanguage
        if selectedCell == indexPath.item{
            cell.titleForSoundLabel.textColor = UIColor.getThemeTextColor()
        }
        else {
            cell.titleForSoundLabel.textColor = .white
        }
        if indexPath.item == 0{
          
            cell.addSubview(languageMenuSeperator2)
            cell.addConstraintsWithFormat("H:|-30-[v0]-30-|", views: languageMenuSeperator2)
            cell.addConstraintsWithFormat("V:[v0(2)]|", views: languageMenuSeperator2)
        }
        
        cell.language = self.languagesSource![indexPath.item]
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.width, height:DeviceType.isIpad() ? 70 : 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedCell = indexPath.item
        UserDefaults.standard.set(String(indexPath.item+1), forKey: "selectedLanguageCode")
        self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "title.language").uppercased()
        collectionView.reloadData()
        
        let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background)
        backgroundQueue.async {
            HomeViewController.setNotificationForDailyMsg()
            self.changeLanguageOfNotification()
        }
      
        if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
            let queryString = "/users/\(userId)/languages/\(indexPath.item+1)"
            
            ApiRequst.doRequest(requestType: .PUT, queryString: queryString, parameter: nil, showHUD: false, completionHandler: { (json) in
                
                DispatchQueue.main.async(execute: {
                    ShowHud.show()
                    self.perform(#selector(self.hideHudAfterDelay), with: nil, afterDelay: 10)
                })
                
            })
        
        }
    }
    
    
    @objc func hideHudAfterDelay(){
        ShowHud.hide()
    }
    
    func changeLanguageOfNotification(){
        if let notifications = UIApplication.shared.scheduledLocalNotifications{
            for notification in notifications{
                if let userInfo = notification.userInfo,let key = userInfo.keys.first as? String{
                    if key.lowercased() == "reminder"{
                        
                        UIApplication.shared.cancelLocalNotification(notification)
                        notification.alertBody = Vocabulary.getWordFromKey(key: "daily_notification.popup.title")
                        UIApplication.shared.scheduleLocalNotification(notification)
                        
                    }else if key.lowercased() == "happy_notification"{
                     
                        UIApplication.shared.cancelLocalNotification(notification)
                        notification.alertBody = Vocabulary.getWordFromKey(key: "notification.happy_msg")
                        UIApplication.shared.scheduleLocalNotification(notification)
                    
                    }
                    
                }
            }
        }
    }
    
    
    
    //MARK: Other Methods
    override func backButtonActionHandeler(){
        self.popToHomeView()
    }
    
    func setUpViews(){
    
        self.backgroudImageView.addSubview(collectionViewForLanguages)
        self.backgroudImageView.addConstraintsWithFormat("H:|[v0]|", views: collectionViewForLanguages)
        self.collectionViewForLanguages.topAnchor.constraint(equalTo: self.customNavigationImageView.bottomAnchor, constant: 0).isActive = true
        self.collectionViewForLanguages.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        
        if String.getSelectedLanguage() == "1"{
            selectedCell = 0
        }else{
            selectedCell = 1
        }
        
        let eng = Language()
        eng.title = "English"
        eng.imageName = "flag_eng"
        
        let svenska = Language()
        svenska.title = "Svenska"
        svenska.imageName = "flag_svenska"
        
        self.languagesSource = [eng,svenska]
        
    }
}



class CellForLanguage:BaseCell{
    

    var language:Language?
    {
        didSet{
            if let title = language?.title{
                    titleForSoundLabel.text = title.uppercased()
            }
        }
    }
    
   var titleForSoundLabel:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 16 : 14, weight: UIFont.Weight(rawValue: 0))
        label.textColor = UIColor.rgb(24, green: 16, blue: 143)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.text = "N/A"
        return label
    }()
    
  
    override func setUpCell() {
        self.backgroundColor = UIColor.init(white: 1, alpha: 0)
        
        self.addSubview(titleForSoundLabel)
     
        self.addConstraintsWithFormat("H:|[v0]|", views: titleForSoundLabel)
        self.addConstraintsWithFormat("V:|[v0]|", views: titleForSoundLabel)
    }
 
}




