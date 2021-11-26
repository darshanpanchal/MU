//
//  GeneralViewController.swift
//  mindsUnlimited
//
//  Created by IPS on 02/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit

class GeneralViewController: UIViewController {
    
    static var navigationObject:UINavigationController?
   
    //MARK: Class propertis
    let customNavigationImageView:UIImageView={
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.tag = 421
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
    let backgroudImageView:UIImageView={
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = #imageLiteral(resourceName: "background")
        iv.contentMode = .scaleToFill
        return iv
    }()
    
    let badgeSize:CGFloat = DeviceType.isIpad() ? 22 : 18
    
    static let labelBadge:UILabel={
        let label = UILabel()
        label.backgroundColor = .red
        label.textColor = .white
        label.text = "10"
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        label.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight(rawValue: -2))
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    lazy var showMenuButton:UIButton={
        let button = UIButton()
        button.adjustsImageWhenHighlighted = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 20
        button.setImage(#imageLiteral(resourceName: "sidemenu"), for: .normal)
        button.addTarget(self, action: #selector(self.showSideMenu), for: .touchUpInside)
        button.addSubview(GeneralViewController.labelBadge)
        GeneralViewController.labelBadge.heightAnchor.constraint(equalToConstant: self.badgeSize).isActive = true
        GeneralViewController.labelBadge.layer.cornerRadius = self.badgeSize/2
        GeneralViewController.labelBadge.widthAnchor.constraint(equalToConstant: self.badgeSize).isActive = true
        GeneralViewController.labelBadge.topAnchor.constraint(equalTo: button.topAnchor, constant: 10).isActive = true
        GeneralViewController.labelBadge.rightAnchor.constraint(equalTo: button.rightAnchor, constant: -5).isActive = true
        
        return button
    }()
    
    lazy var backButtonOnNavigationView:UIButton={
        let button = UIButton()
        button.adjustsImageWhenHighlighted = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 20
        button.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        button.addTarget(self, action: #selector(self.backButtonActionHandeler), for: .touchUpInside)
        return button
    }()
    
    lazy var labelTitleOnNavigation:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 29.5 : UIScreen.main.bounds.height < 481 ? 20 : 24)
        label.textColor = UIColor.getYellowishColor()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        if String.getSelectedLanguage() == "2"{
            label.numberOfLines = 2
        }
        label.text = Vocabulary.getWordFromKey(key: "title.home").uppercased()
        return label
    }()
    
    enum ViewControllerList {
        case home
        case register
        case reminder
        case notifications
        case profile
        case groups
        case statistics
        case language
        case aboutUs
        case meditate
    }
  
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        self.view.backgroundColor = .white
        GeneralViewController.navigationObject = self.navigationController // Because it gets nil while accessing though other class (from sideMenu controller)
        self.setupCustomNavigationBar()
   }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    //MARK: Other methods
    func setupCustomNavigationBar(){
        self.view.addSubview(backgroudImageView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: backgroudImageView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: backgroudImageView)
        
        let heightOfNavigation:CGFloat = DeviceType.isIpad() ? 65 : 50
        backgroudImageView.addSubview(customNavigationImageView)
        backgroudImageView.addConstraintsWithFormat("H:|[v0]|", views: customNavigationImageView)
        backgroudImageView.addConstraintsWithFormat("V:|[v0(\(heightOfNavigation))]", views: customNavigationImageView)
        
        customNavigationImageView.addSubview(showMenuButton)
        customNavigationImageView.addSubview(labelTitleOnNavigation)
        customNavigationImageView.addSubview(backButtonOnNavigationView)
        
        customNavigationImageView.addConstraintsWithFormat("H:|[v0(\(heightOfNavigation))]-2-[v1]-2-[v2(\(heightOfNavigation))]|", views: backButtonOnNavigationView,labelTitleOnNavigation,showMenuButton)
        customNavigationImageView.addConstraintsWithFormat("V:|[v0]|", views: showMenuButton)
        customNavigationImageView.addConstraintsWithFormat("V:|[v0]|", views: labelTitleOnNavigation)
        customNavigationImageView.addConstraintsWithFormat("V:|[v0]|", views: backButtonOnNavigationView)
        
        let seperatorView = UIView()
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        seperatorView.backgroundColor = UIColor.getThemeTextColor()
        seperatorView.alpha = 0
        
        self.customNavigationImageView.addSubview(seperatorView)
        self.customNavigationImageView.addConstraintsWithFormat("H:|[v0]|", views: seperatorView)
        self.customNavigationImageView.addConstraintsWithFormat("V:[v0(0.3)]|", views: seperatorView)
  
    }
    
    
    func goToViewController(toViewController:ViewControllerList,backToParentWhenDone:Bool = false){
        
        DispatchQueue.main.async {
            let dvc:UIViewController?
            switch toViewController {
            case .home:
                dvc = HomeViewController()
                GoogleAnalytics.setScreen(name: "Home Screen", className: "HomeViewController")
                
            case .groups:
                dvc = GroupsView()
                GoogleAnalytics.setScreen(name: "Group main Screen", className: "GroupsView")
                
            case .language:
                dvc = LanguageView()
                GoogleAnalytics.setScreen(name: "Language Screen", className: "LanguageView")
            case .profile:
                let pv = ProfileView()
                pv.cameFromGroupView = backToParentWhenDone
                GoogleAnalytics.setScreen(name: "User Profile Screen", className: "ProfileView")
                dvc = pv
            case .reminder:
                dvc = ReminderSettings()
                GoogleAnalytics.setScreen(name: "Reminder Settings Screen", className: "ReminderSettings")
            case .notifications:
                dvc = NotificationsView()
                 GoogleAnalytics.setScreen(name: "Notifications Screen", className: "NotificationsView")
            case .register:
                dvc = RegisterAndLoginView()
                 GoogleAnalytics.setScreen(name: "Register And Login Screen", className: "RegisterAndLoginView")
            case .statistics:
                dvc = StatisticsView()
                  GoogleAnalytics.setScreen(name: "Statistics Screen", className: "StatisticsView")
            case .aboutUs:
                dvc = AboutUsView()
                  GoogleAnalytics.setScreen(name: "About Screen", className: "AboutUsView")
            case .meditate:
                dvc = MeditationView()
                GoogleAnalytics.setScreen(name: "My Meditations Screen", className: "AboutUsView")
            }
            if let destionationViewController = dvc{
                GeneralViewController.navigationObject?.pushViewController(destionationViewController, animated: false)
            }
        }
  
    }
    
    func popToHomeView(){
       
        self.view.endEditing(true)
       
        self.view.window?.backgroundColor = .white
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromLeft
        
        self.navigationController!.view.layer.add(transition, forKey: nil)
        
        self.goToViewController(toViewController: .home)
        
        ShowSideMenu.showSideMenuObj.selectedCell = 0
        ShowSideMenu.showSideMenuObj.listingCollectionView.reloadData()
  
    }
    
    @objc func showSideMenu(){
        //GoogleAnalytics.setEvent(id: "showSideMenu", title: "Show Side Menu Button")
        self.view.endEditing(true)
        ShowSideMenu.showSideMenu()
    }
    
    @objc func backButtonActionHandeler(){
       // GoogleAnalytics.setEvent(id: "general_back_button", title: "General Back Button")
        self.view.endEditing(true)
        self.navigationController!.popViewController(animated: true)
    }
    
  
}


