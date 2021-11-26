//
//  ShowSideMenu.swift
//  NANOTECH
//
//  Created by IPS on 24/12/16.
//  Copyright © 2016 itpathsolution. All rights reserved.
//

import UIKit

class ShowSideMenu: GeneralViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate,customAlertDelegates {
    
    //MARK: Properties
    static let showSideMenuObj = ShowSideMenu()
    static let backGroundView:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 0.2, alpha: 0)
        return view
    }()
    static var collectionViewContainer:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.blue
    
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "background")
        imageView.contentMode = .scaleToFill
        view.addSubview(imageView)
        view.addConstraintsWithFormat("H:|[v0]|", views: imageView)
        view.addConstraintsWithFormat("V:|[v0]|", views: imageView)
        
        return view
    }()
    
    var selectedCell = 0
    static var leftPos:NSLayoutConstraint?
    var currentWindow:UIWindow?
    lazy var listingCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(SideMenuCell.self, forCellWithReuseIdentifier:"cellID")
        cv.register(HeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerID")
        return cv
    }()
    
    
    static var restoreButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        button.backgroundColor = .clear
        button.tag = 10
        let fontSize:CGFloat = DeviceType.isIpad() ? 20 : (UIScreen.main.bounds.height < 569 ? 13 : 16)
        button.titleLabel?.font =  UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight(rawValue: 0))
        button.addTarget(ShowSideMenu.self, action: #selector(ShowSideMenu.handelButtonActionOfRegisterView), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    
    static var mangeButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        button.backgroundColor = .clear
        button.tag = 20
        let fontSize:CGFloat = DeviceType.isIpad() ? 20 : (UIScreen.main.bounds.height < 569 ? 13 : 16)
        button.titleLabel?.font =  UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight(rawValue: 0))
        button.addTarget(ShowSideMenu.self, action: #selector(ShowSideMenu.handelButtonActionOfRegisterView), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    
    static var sideMenuWidth:CGFloat = 250
    var dataSourceArray:[[String:String]]?
   
    //MARK: Custom Methods
    class func showSideMenu()
    {
        mangeButton.setTitle(Vocabulary.getWordFromKey(key: "inapp.manage_subscription").uppercased(), for: .normal)
        restoreButton.setTitle(Vocabulary.getWordFromKey(key: "inapp.restore_subscription").uppercased(), for: .normal)
       
        if let app = UIApplication.shared.delegate as? AppDelegate , let window = app.window
        {
            
            if let userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject],let _ = userDetails["Email"] as? String{
               ShowSideMenu.setSideMenuDataSource(isLoggedIn: true)
            }else{
                ShowSideMenu.setSideMenuDataSource(isLoggedIn: false)
            }
            
          
            sideMenuWidth = UIScreen.main.bounds.width/1.5
            
            showSideMenuObj.currentWindow = window
            window.addSubview(backGroundView)
            
            backGroundView.topAnchor.constraint(equalTo: window.topAnchor, constant: 0).isActive = true
            backGroundView.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: 0).isActive = true
            backGroundView.rightAnchor.constraint(equalTo: window.rightAnchor, constant: 0).isActive = true
            backGroundView.leftAnchor.constraint(equalTo: window.leftAnchor, constant: 0).isActive = true
            
            backGroundView.addSubview(collectionViewContainer)
            collectionViewContainer.topAnchor.constraint(equalTo:backGroundView.topAnchor, constant: 0).isActive = true
            collectionViewContainer.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: 0).isActive = true
            collectionViewContainer.widthAnchor.constraint(equalToConstant:sideMenuWidth).isActive = true
            leftPos = NSLayoutConstraint(item: collectionViewContainer, attribute: .left, relatedBy: .equal, toItem: backGroundView, attribute: .right, multiplier: 1, constant: 0)
            backGroundView.addConstraint(leftPos!)
            
            collectionViewContainer.addSubview(showSideMenuObj.listingCollectionView)
            
            collectionViewContainer.addSubview(restoreButton)
            collectionViewContainer.addSubview(mangeButton)
         
            collectionViewContainer.addConstraintsWithFormat("H:|-10-[v0]-2-|", views: restoreButton)
            collectionViewContainer.addConstraintsWithFormat("H:|-10-[v0]-2-|", views: mangeButton)
            
            collectionViewContainer.addConstraintsWithFormat("H:|[v0]|", views: showSideMenuObj.listingCollectionView)
            let gap = (UIScreen.main.bounds.height < 569 ? 7 : 17)
            collectionViewContainer.addConstraintsWithFormat("V:|[v0]-10-[v1(20)]-\(gap)-[v2(20)]-15-|", views: showSideMenuObj.listingCollectionView,restoreButton,mangeButton)
            
            let swip = UISwipeGestureRecognizer(target: self, action: #selector(gestureCalled))
            swip.delegate = showSideMenuObj
            swip.direction = .right
            backGroundView.addGestureRecognizer(swip)
            
            let tap = UITapGestureRecognizer(target: self, action:#selector(hideMenu))
            tap.delegate = showSideMenuObj
            backGroundView.addGestureRecognizer(tap)
            window.layoutIfNeeded()
            leftPos?.constant = -sideMenuWidth
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                window.layoutIfNeeded()
                backGroundView.backgroundColor = UIColor.init(white: 0.2, alpha: 0.5)
                }, completion: { (Bool) in
            })
        }
        
        
        
    }
    @objc class func gestureCalled(gesture:UISwipeGestureRecognizer)
    {
        if gesture.direction == .right
        {
           hideMenu()
        }
    }

    @objc class func hideMenu()
    {
        DispatchQueue.main.async {
        leftPos?.constant = 0
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            showSideMenuObj.currentWindow?.layoutIfNeeded()
           backGroundView.backgroundColor = UIColor.init(white: 0.2, alpha: 0)
        }, completion: { (Bool) in
            
            ShowSideMenu.backGroundView.removeFromSuperview()
            for subview in backGroundView.subviews{
                subview.removeFromSuperview()
            }
            
            
        })
        }
    }
    @objc static func handelButtonActionOfRegisterView(sender:UIButton){
        
        
        if sender.tag == 10{
            GoogleAnalytics.setEvent(id: "restore_purchase", title: "Restore Purchase Button")
            InAppManager.shared.loadProducts(operation: .restore)
        }else{
            GoogleAnalytics.setEvent(id: "manage_subscription", title: "Manage Subscription Button")
            let application = UIApplication.shared
           
            if let url = URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions"){
                if !application.openURL(url){
                    
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
                }
            }
        }
    }
    
  
    //MARK: CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 50)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if let count = dataSourceArray?.count{
            return count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if currentWindow == nil
        {
            return CGSize(width:0, height: 0)
        }
        return CGSize(width:collectionView.frame.width, height: DeviceType.isIpad() ? 65 : 40)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! SideMenuCell
       
        let fontSize:CGFloat = DeviceType.isIpad() ? 20 : 16
        cell.titleLbl.font = selectedCell == indexPath.item ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        cell.titleLbl.text = self.dataSourceArray![indexPath.item].keys.first
       
        let key = self.dataSourceArray![indexPath.item].values.first
        
        if (key == "statistics" || key == "reminder") && !String.has_full_access(){
           
              cell.widthOfLockImage?.constant = DeviceType.isIpad() ? 25 : 20
            
        }else{
            cell.widthOfLockImage?.constant = 0
        }
        
        let result = DBManger.dbGenericQuery(queryString: "SELECT * FROM notifications where hasRead = '\(false)' AND is_badge_enabled = '\(true)'")
        cell.widthOfBadgeLabel?.constant = 0
        if result.count != 0, key == "notifications"{
            cell.rightAnchorForLabel?.isActive = false
            cell.widthOfBadgeLabel?.constant = cell.badgeSize
            cell.labelBadge.text = String(result.count)
            GeneralViewController.labelBadge.text = String(result.count)
        }else{
            cell.rightAnchorForLabel?.isActive = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind:UICollectionElementKindSectionHeader , withReuseIdentifier: "headerID", for: indexPath)
        return header
      
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        let key = self.dataSourceArray![indexPath.item].values.first!
        
        if (key == "reminder" || key == "statistics") && !String.has_full_access(){
            self.showSubscribeAlert()
            return
        }
        
        if key == "rate_us"{
            
            CustomAlerView.delegation = self
            CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "general_no"),Vocabulary.getWordFromKey(key: "title.rate_now")], titleMsg: Vocabulary.getWordFromKey(key: "ratting_alert.title.give_rattings"), desciption: Vocabulary.getWordFromKey(key: "subtitlle.give_rattings"), userInfo: ["rate_us":"rate_us" as AnyObject])
       
            return
        }
        
        ShowSideMenu.hideMenu()
        if indexPath.item == selectedCell{
            return
        }
    
        self.selectedCell = indexPath.item
        self.listingCollectionView.reloadData()
        switch key {
        case "home":
            self.goToViewController(toViewController: .home)
        case "register":
            self.goToViewController(toViewController: .register)
        case "reminder":
            self.goToViewController(toViewController: .reminder)
        case "notifications":
            self.goToViewController(toViewController: .notifications)
        case "profile":
             self.goToViewController(toViewController: .profile)
        case "group":
              self.goToViewController(toViewController: .groups)
        case "statistics":
             self.goToViewController(toViewController: .statistics)
        case "language":
              self.goToViewController(toViewController: .language)
        case "aboutus":
              self.goToViewController(toViewController: .aboutUs)
        default:
            self.goToViewController(toViewController: .home)
            break
        }
    }
   
    //MARK: Gesture delegates
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == ShowSideMenu.backGroundView ? true : false
    }
    
    static func setSideMenuDataSource(isLoggedIn:Bool){
        if isLoggedIn{
            
            showSideMenuObj.dataSourceArray = [[Vocabulary.getWordFromKey(key: "title.home").uppercased():"home"],[Vocabulary.getWordFromKey(key: "title.log_out").uppercased():"register"],[Vocabulary.getWordFromKey(key: "sidemenu.title.reminder_settings").uppercased():"reminder"],[Vocabulary.getWordFromKey(key: "sidemenu.title.notification").uppercased():"notifications"],[Vocabulary.getWordFromKey(key: "title.profile").uppercased():"profile"],[Vocabulary.getWordFromKey(key: "general_group").uppercased():"group"],[Vocabulary.getWordFromKey(key: "general.title.statistics").uppercased():"statistics"],[Vocabulary.getWordFromKey(key: "title.language").uppercased():"language"],[Vocabulary.getWordFromKey(key: "title.about_us").uppercased():"aboutus"]]
        }else{
             showSideMenuObj.dataSourceArray = [[Vocabulary.getWordFromKey(key: "title.home").uppercased():"home"],[Vocabulary.getWordFromKey(key: "title.register").uppercased():"register"],[Vocabulary.getWordFromKey(key: "sidemenu.title.reminder_settings").uppercased():"reminder"],[Vocabulary.getWordFromKey(key: "title.language").uppercased():"language"],[Vocabulary.getWordFromKey(key: "title.about_us").uppercased():"aboutus"]]
        }
        
        
        if let has_rated = UserDefaults.standard.object(forKey: "rate_us") as? Bool,has_rated{
            //Already rated
        }else{
           
            for (index,object) in showSideMenuObj.dataSourceArray!.enumerated(){
                if object.values.first! == "aboutus"{
                    showSideMenuObj.dataSourceArray!.insert([Vocabulary.getWordFromKey(key: "title.rate_now").uppercased():"rate_us"], at: index)
                }
            }
        }
        
        
        showSideMenuObj.listingCollectionView.reloadData()
    }
  
    func showSubscribeAlert(){
        
        InAppManager.shared.loadProducts(operation: .buy)
       
        return
 }
   
    func didTappedCustomAletButton(selectedIndex: Int, title: String, userInfo: [String : AnyObject]?) {
        if selectedIndex == 1{
            if let user_info = userInfo,user_info["rate_us"] != nil{
                if let url = URL(string : "itms-apps://itunes.apple.com/app/id1110506727"){
                    UIApplication.shared.openURL(url)
                    ShowSideMenu.hideMenu()
                    
                    var params = [String:Any]()
                    params["IMEI"] = UIDevice.current.identifierForVendor!.uuidString
                    
                    if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
                        params["UserId"] = userId
                    }
                    params["IsWebRated"] = true
                    
                    ApiRequst.doRequest(requestType: .POST, queryString: "basedata/rate/webrated", parameter: params as [String : AnyObject],showHUD: false, completionHandler: { (response) in
                        
                        UserDefaults.standard.set(true, forKey: "rate_us")
                        
                    })
                    
                }
            }else {
                InAppManager.shared.loadProducts(operation: .buy)
            }
        }
    }
}

class SideMenuCell:SuperCell{
    
    var widthOfLockImage:NSLayoutConstraint?
    var rightAnchorForLabel:NSLayoutConstraint?
    
    var widthOfBadgeLabel:NSLayoutConstraint?
    let badgeSize:CGFloat = DeviceType.isIpad() ? 22 : 18
    
    lazy var titleLbl:UILabel={
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = Vocabulary.getWordFromKey(key: "unknown﻿").capitalized
        lbl.textColor = UIColor.getThemeTextColor()
        lbl.backgroundColor = .clear
        lbl.adjustsFontSizeToFitWidth = true
        lbl.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 0))
        return lbl
    }()
    
    
    let lockImageView:UIImageView={
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "lock").withRenderingMode(.alwaysTemplate)
        iv.tintColor = UIColor.getThemeTextColor()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
     let labelBadge:UILabel={
        let label = UILabel()
        label.backgroundColor = .red
        label.textColor = .white
        label.text = "0"
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        label.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight(rawValue: -2))
        label.textAlignment = .center
        return label
    }()
    
    override func setUpViews() {
        self.backgroundColor = .clear
        self.addSubview(titleLbl)
        self.addSubview(lockImageView)
        
        let sizeOfLockImage:CGFloat = DeviceType.isIpad() ? 25 : 20
      
        
        lockImageView.heightAnchor.constraint(equalToConstant: sizeOfLockImage).isActive = true
        widthOfLockImage = lockImageView.widthAnchor.constraint(equalToConstant: sizeOfLockImage)
        self.addConstraint(widthOfLockImage!)
        lockImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        lockImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
   
        titleLbl.leftAnchor.constraint(equalTo: self.lockImageView.rightAnchor,constant:10).isActive = true
        titleLbl.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        titleLbl.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
      
        rightAnchorForLabel = titleLbl.rightAnchor.constraint(equalTo: self.rightAnchor,constant:-2)
        self.addConstraint(rightAnchorForLabel!)
        
        self.addSubview(labelBadge)
        labelBadge.layer.cornerRadius = self.badgeSize/2
        labelBadge.heightAnchor.constraint(equalToConstant: badgeSize).isActive = true
        widthOfBadgeLabel = labelBadge.widthAnchor.constraint(equalToConstant: badgeSize)
        self.addConstraint(widthOfBadgeLabel!)
        labelBadge.leftAnchor.constraint(equalTo: titleLbl.rightAnchor, constant: 5).isActive = true
        labelBadge.centerYAnchor.constraint(equalTo: self.centerYAnchor,constant: -10).isActive = true
   
        
    }
   
}
class HeaderCell:UICollectionReusableView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

