//
//  RegisterAndLoginView.swift
//  mindsUnlimited
//
//  Created by IPS on 03/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit

class RegisterAndLoginView:GeneralViewController,UITextFieldDelegate,customAlertDelegates{
    //MARK: Class properties
    enum RegisterViewType {
        case login
        case logout
        case recovery
        case createAccount
        case codeReceived
    }
    
    var currentViewType = RegisterViewType.login
    let heightOftextField:CGFloat = DeviceType.isIpad() ? 55 : 40
    
    lazy var aliasNameTextfield:CustomTextField={
        let txt = CustomTextField()
        txt.delegate = self
        txt.translatesAutoresizingMaskIntoConstraints = false
        txt.placeholder = Vocabulary.getWordFromKey(key: "general.title.name_alias").uppercased()
        txt.textAlignment = .left
        txt.layer.masksToBounds = true
        txt.textColor = UIColor.getThemeTextColor()
        txt.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 17 : 15)
        txt.keyboardType = .emailAddress
        txt.returnKeyType = .next
        return txt
    }()
    
    lazy var emailTextField:CustomTextField={
        let txt = CustomTextField()
        txt.delegate = self
        txt.translatesAutoresizingMaskIntoConstraints = false
        txt.placeholder = Vocabulary.getWordFromKey(key: "register_and_login.email").uppercased()
        txt.textAlignment = .left
        txt.layer.masksToBounds = true
        txt.textColor = UIColor.getThemeTextColor()
        txt.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 17 : 15)
        txt.keyboardType = .emailAddress
        txt.returnKeyType = .next
        
        return txt
    }()
    
    lazy var passwordTextField:CustomTextField={
        let txt = CustomTextField()
        txt.delegate = self
        txt.translatesAutoresizingMaskIntoConstraints = false
        txt.placeholder = Vocabulary.getWordFromKey(key: "register_and_login.password").uppercased()
        txt.textAlignment = .left
        txt.layer.masksToBounds = true
        txt.isSecureTextEntry = true
        txt.textColor = UIColor.getThemeTextColor()
        txt.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 17 : 15)
        txt.returnKeyType = .default
        return txt
    }()
    lazy var confirmPasswordTextField:CustomTextField={
        let txt = CustomTextField()
        txt.delegate = self
        txt.translatesAutoresizingMaskIntoConstraints = false
        txt.placeholder = Vocabulary.getWordFromKey(key: "register_and_login.confirm_password").uppercased()
        txt.textAlignment = .left
        txt.layer.masksToBounds = true
        txt.isSecureTextEntry = true
        txt.textColor = UIColor.getThemeTextColor()
        txt.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 17 : 15)
        txt.returnKeyType = .default
        return txt
    }()
    
    lazy var recoveryCodeTextfield:CustomTextField={
        let txt = CustomTextField()
        txt.delegate = self
        txt.translatesAutoresizingMaskIntoConstraints = false
        txt.placeholder = Vocabulary.getWordFromKey(key: "register_and_login.label.enter_recover_code").uppercased()
        txt.textAlignment = .left
        txt.layer.masksToBounds = true
        txt.textColor = UIColor.getThemeTextColor()
        txt.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 17 : 15)
        txt.returnKeyType = .default
        return txt
    }()
    
    lazy var loginButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        button.backgroundColor = .white
        button.setTitle(Vocabulary.getWordFromKey(key: "register_and_login.button.ttile.login").uppercased(), for: .normal)
        button.tag = 10
        button.layer.cornerRadius = 22
        button.titleLabel?.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : 16)
        button.addTarget(self, action: #selector(self.handelButtonActionOfRegisterView), for: .touchUpInside)
        button.showShadow()
        return button
    }()
    
    var isRememberTrue = true
    lazy var rememberMeImageView:UIImageView={
        let iv = UIImageView()
        let unChecked = #imageLiteral(resourceName: "unChecked").withRenderingMode(.alwaysTemplate)
        let checkedImage = #imageLiteral(resourceName: "checked").withRenderingMode(.alwaysTemplate)
        iv.image = checkedImage
        iv.tintColor = UIColor.getThemeTextColor()
        iv.translatesAutoresizingMaskIntoConstraints = false
        if let loginCredentials = UserDefaults.standard.object(forKey: "loginCredentials") as? [String:AnyObject]{
            if let rememberMe = loginCredentials["rememberMe"] as? String,rememberMe.lowercased() == "true"{
                iv.image = checkedImage
                self.isRememberTrue = true
            }else{
                iv.image = unChecked
                self.isRememberTrue = false
            }
        }
        return iv
    }()
    
    
    lazy var rememberMeButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.getYellowishColor(), for: .normal)
        button.backgroundColor = UIColor.init(white: 0, alpha: 0)
        button.setTitle(Vocabulary.getWordFromKey(key: "register_and_login.button.remember_me").capitalizingFirstLetter(), for: .normal)
        button.tag = 20
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(self.handelButtonActionOfRegisterView), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize:  DeviceType.isIpad() ? 16 : 14, weight: UIFont.Weight(rawValue: 0))
        button.contentHorizontalAlignment = .right
        button.tintColor = UIColor.getThemeTextColor()
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        
        button.addSubview(self.rememberMeImageView)
        self.rememberMeImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        self.rememberMeImageView.rightAnchor.constraint(equalTo: button.rightAnchor, constant: DeviceType.isIpad() ? -125 : -105).isActive = true
        let size:CGFloat = DeviceType.isIpad() ? 30 : 20
        self.rememberMeImageView.heightAnchor.constraint(equalToConstant: size).isActive = true
        self.rememberMeImageView.widthAnchor.constraint(equalToConstant: size).isActive = true
        
        return button
    }()
    
    lazy var fabeBookButton:UIButton={
        let button = UIButton()
         button.showShadow()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        button.backgroundColor = .white
        button.setTitle(Vocabulary.getWordFromKey(key: "register_and_login.login_fb").uppercased(), for: .normal)
        button.tag = 30
        button.layer.cornerRadius = 22
        button.titleLabel?.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : 16)
        button.addTarget(self, action: #selector(self.handelButtonActionOfRegisterView), for: .touchUpInside)
        button.contentHorizontalAlignment = .center
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20)
        let image = #imageLiteral(resourceName: "facebookWhite").withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor.getThemeTextColor()
        button.addSubview(imageView)
        button.addConstraintsWithFormat("H:|-20-[v0(\(self.heightOftextField-10))]", views: imageView)
        button.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: imageView)
        
        return button
    }()
    
    
    lazy var createAccountButton:UIButton={
        let button = UIButton()
        button.showShadow()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        button.backgroundColor = .white
        button.setTitle(Vocabulary.getWordFromKey(key: "register_and_login.button_title.create_account").uppercased(), for: .normal)
        button.tag = 40
        button.layer.cornerRadius = 22
        button.titleLabel?.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : 16)
        button.addTarget(self, action: #selector(self.handelButtonActionOfRegisterView), for: .touchUpInside)
        button.contentHorizontalAlignment = .center
        
        let image = #imageLiteral(resourceName: "create_account").withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor.getThemeTextColor()
        
        button.addSubview(imageView)
        button.addConstraintsWithFormat("H:|-20-[v0(\(self.heightOftextField-10))]", views: imageView)
        button.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: imageView)
        
        return button
    }()
    
    let imageViewForRecoveryButton = UIImageView()
    lazy var recoveryButton:UIButton={
        let button = UIButton()
        button.showShadow()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        button.backgroundColor = .white
        button.setTitle(Vocabulary.getWordFromKey(key: "register_and_login.recovery").uppercased(), for: .normal)
        button.tag = 50
        button.layer.cornerRadius = 22
        button.titleLabel?.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : 16)
        button.addTarget(self, action: #selector(self.handelButtonActionOfRegisterView), for: .touchUpInside)
        button.contentHorizontalAlignment = .center
        
        let image = #imageLiteral(resourceName: "password_recovery").withRenderingMode(.alwaysTemplate)
        self.imageViewForRecoveryButton.image = image
        self.imageViewForRecoveryButton.translatesAutoresizingMaskIntoConstraints = false
        self.imageViewForRecoveryButton.tintColor = UIColor.getThemeTextColor()
        
        button.addSubview(self.imageViewForRecoveryButton)
        button.addConstraintsWithFormat("H:|-20-[v0(\(self.heightOftextField-10))]", views: self.imageViewForRecoveryButton)
        button.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: self.imageViewForRecoveryButton)
        
        return button
    }()
    
    lazy var buttonCodeRecieved:UIButton={
        let button = UIButton()
        button.showShadow()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        button.backgroundColor = .white
        button.setTitle(Vocabulary.getWordFromKey(key: "register_and_login.code_received").uppercased(), for: .normal)
        button.tag = 60
        button.layer.cornerRadius = 22
        button.titleLabel?.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : 16)
        button.addTarget(self, action: #selector(self.handelButtonActionOfRegisterView), for: .touchUpInside)
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    let logInInformation:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor.getThemeTextColor()
        label.text = "N/A"
        return label
    }()
    
    //MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
          if let userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject],let _ = userDetails["Email"] as? String{
              self.currentViewType = .logout
          }
          self.setUpBasicView()
        
    }
    
    //MARK: Custom Methods
    func setUpBasicView(){
        
        
        for view in self.backgroudImageView.subviews{
            if view.tag != 421{
                view.removeFromSuperview()
            }
        }
        
        
        //Removing text field's text -
        self.passwordTextField.text = ""
        self.confirmPasswordTextField.text = ""
        self.recoveryCodeTextfield.text = ""
        self.aliasNameTextfield.text = ""
        imageViewForRecoveryButton.isHidden = true
        
        
        
        let paddingForiPhone:CGFloat = Int(UIScreen.main.bounds.width) > 320 ? 40 : 15
        let padding:CGFloat =  DeviceType.isIpad() ? 100 : paddingForiPhone
        
        
        switch currentViewType {
        case .login:
            imageViewForRecoveryButton.isHidden = false
            
            self.emailTextField.text = ""
            
            UserDefaults.standard.removeObject(forKey: "userDetails")
            UserDefaults.standard.removeObject(forKey: "offlineReadNotifications")
        
            _ = DBManger.dbGenericQuery(queryString: "DELETE FROM notifications")
            AppDelegate.setBadgeNumber()
           
            recoveryButton.setTitle(Vocabulary.getWordFromKey(key: "register_and_login.recovery").uppercased(), for: .normal)
            
            
            self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "title.register").uppercased()
            self.emailTextField.returnKeyType = .next
            self.passwordTextField.returnKeyType = .done
            
            if let loginCredentials = UserDefaults.standard.object(forKey: "loginCredentials") as? [String:AnyObject]{
                
                if let rememberMe = loginCredentials["rememberMe"] as? String,rememberMe.lowercased() == "true"{
                    if let email = loginCredentials["email"] as? String{
                        self.emailTextField.text = email
                    }
                    if let pass = loginCredentials["pass"] as? String{
                        self.passwordTextField.text = pass
                    }
                    
                }
            }
            
            self.backgroudImageView.addSubview(emailTextField)
            self.backgroudImageView.addSubview(passwordTextField)
            self.backgroudImageView.addSubview(loginButton)
            self.backgroudImageView.addSubview(rememberMeButton)
            self.backgroudImageView.addSubview(fabeBookButton)
            self.backgroudImageView.addSubview(createAccountButton)
            self.backgroudImageView.addSubview(recoveryButton)
            
            
            emailTextField.topAnchor.constraint(equalTo: self.customNavigationImageView.bottomAnchor, constant: DeviceType.isIpad() ? 60 : 30).isActive = true
            emailTextField.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            emailTextField.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant: -padding).isActive = true
            emailTextField.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant:padding).isActive = true
            
            passwordTextField.topAnchor.constraint(equalTo: self.emailTextField.bottomAnchor, constant: 0).isActive = true
            passwordTextField.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            passwordTextField.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            passwordTextField.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant:padding).isActive = true
            
            loginButton.topAnchor.constraint(equalTo: self.passwordTextField.bottomAnchor, constant: DeviceType.isIpad() ? 20 : 10).isActive = true
            loginButton.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            loginButton.widthAnchor.constraint(equalTo: self.passwordTextField.widthAnchor, multiplier: 0.4).isActive = true
            loginButton.leftAnchor.constraint(equalTo: self.passwordTextField.leftAnchor, constant: 0).isActive = true
            
            rememberMeButton.topAnchor.constraint(equalTo: self.passwordTextField.bottomAnchor, constant: DeviceType.isIpad() ? 20 : 10).isActive = true
            rememberMeButton.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            rememberMeButton.widthAnchor.constraint(equalTo: self.passwordTextField.widthAnchor, multiplier: 0.5).isActive = true
            rememberMeButton.rightAnchor.constraint(equalTo: self.passwordTextField.rightAnchor, constant: -10).isActive = true
            
            fabeBookButton.topAnchor.constraint(equalTo: self.rememberMeButton.bottomAnchor, constant:padding).isActive = true
            fabeBookButton.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            fabeBookButton.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            fabeBookButton.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant:padding).isActive = true
            
            createAccountButton.topAnchor.constraint(equalTo: fabeBookButton.bottomAnchor, constant: DeviceType.isIpad() ? 80 : 60).isActive = true
            createAccountButton.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            createAccountButton.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant: -padding).isActive = true
            createAccountButton.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant: padding).isActive = true
            
            recoveryButton.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: DeviceType.isIpad() ? 20 : 10).isActive = true
            recoveryButton.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            recoveryButton.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            recoveryButton.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant: padding).isActive = true
        case .createAccount:
            self.emailTextField.text = ""
            
            self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "register_and_login.button_title.create_account").uppercased()
            
            self.aliasNameTextfield.returnKeyType = .next
            self.emailTextField.returnKeyType = .next
            self.passwordTextField.returnKeyType = .next
            self.confirmPasswordTextField.returnKeyType = .done
            
            self.backgroudImageView.addSubview(aliasNameTextfield)
            self.backgroudImageView.addSubview(emailTextField)
            self.backgroudImageView.addSubview(passwordTextField)
            self.backgroudImageView.addSubview(confirmPasswordTextField)
            self.backgroudImageView.addSubview(createAccountButton)
            
            aliasNameTextfield.topAnchor.constraint(equalTo: self.customNavigationImageView.bottomAnchor, constant: DeviceType.isIpad() ? 60 : 30).isActive = true
            aliasNameTextfield.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            aliasNameTextfield.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant: -padding).isActive = true
            aliasNameTextfield.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant:padding).isActive = true
            
            emailTextField.topAnchor.constraint(equalTo: self.aliasNameTextfield.bottomAnchor, constant: 0).isActive = true
            emailTextField.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            emailTextField.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            emailTextField.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant:padding).isActive = true
            
            passwordTextField.topAnchor.constraint(equalTo: self.emailTextField.bottomAnchor, constant: 0).isActive = true
            passwordTextField.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            passwordTextField.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            passwordTextField.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant:padding).isActive = true
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: self.passwordTextField.bottomAnchor, constant:0).isActive = true
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            confirmPasswordTextField.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            confirmPasswordTextField.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant:padding).isActive = true
            
            createAccountButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: DeviceType.isIpad() ? 60 : 30).isActive = true
            createAccountButton.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            createAccountButton.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            createAccountButton.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant: padding).isActive = true
        case .recovery:
            
            self.emailTextField.text = ""
            
            self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "register_and_login.recovery").uppercased()
            recoveryButton.setTitle(Vocabulary.getWordFromKey(key: "register_and_login.label.send_recovery").uppercased(), for: .normal)
            
            self.backgroudImageView.addSubview(emailTextField)
            self.backgroudImageView.addSubview(recoveryButton)
            self.backgroudImageView.addSubview(buttonCodeRecieved)
            
            emailTextField.returnKeyType = .default
            emailTextField.topAnchor.constraint(equalTo: self.customNavigationImageView.bottomAnchor, constant: DeviceType.isIpad() ? 60 : 30).isActive = true
            emailTextField.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            emailTextField.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant: -padding).isActive = true
            emailTextField.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant:padding).isActive = true
            
            recoveryButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: DeviceType.isIpad() ? 60 : 30).isActive = true
            recoveryButton.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            recoveryButton.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            recoveryButton.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant: padding).isActive = true
            
            
            buttonCodeRecieved.topAnchor.constraint(equalTo: recoveryButton.bottomAnchor, constant: DeviceType.isIpad() ? 20 : 10).isActive = true
            buttonCodeRecieved.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            buttonCodeRecieved.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            buttonCodeRecieved.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant: padding).isActive = true

        case .codeReceived:
            recoveryButton.setTitle(Vocabulary.getWordFromKey(key: "register_and_login.send_new_pass").uppercased(), for: .normal)
            
            self.emailTextField.returnKeyType = .next
            self.recoveryCodeTextfield.returnKeyType = .next
            self.passwordTextField.returnKeyType = .next
            self.confirmPasswordTextField.returnKeyType = .done
            
            self.backgroudImageView.addSubview(emailTextField)
            self.backgroudImageView.addSubview(recoveryCodeTextfield)
            self.backgroudImageView.addSubview(passwordTextField)
            self.backgroudImageView.addSubview(confirmPasswordTextField)
            
            self.backgroudImageView.addSubview(recoveryButton)
            
            
            emailTextField.topAnchor.constraint(equalTo: self.customNavigationImageView.bottomAnchor, constant: DeviceType.isIpad() ? 60 : 30).isActive = true
            emailTextField.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            emailTextField.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            emailTextField.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant:padding).isActive = true
            
            recoveryCodeTextfield.topAnchor.constraint(equalTo: self.emailTextField.bottomAnchor, constant:0).isActive = true
            recoveryCodeTextfield.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            recoveryCodeTextfield.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            recoveryCodeTextfield.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant:padding).isActive = true
            
            
            passwordTextField.topAnchor.constraint(equalTo: self.recoveryCodeTextfield.bottomAnchor, constant: 0).isActive = true
            passwordTextField.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            passwordTextField.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            passwordTextField.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant:padding).isActive = true
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: self.passwordTextField.bottomAnchor, constant:0).isActive = true
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            confirmPasswordTextField.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            confirmPasswordTextField.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant:padding).isActive = true
            
            recoveryButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: DeviceType.isIpad() ? 60 : 30).isActive = true
            recoveryButton.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            recoveryButton.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            recoveryButton.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant: padding).isActive = true
        case .logout:
            
            if DBManger.dbGenericQuery(queryString: "SELECT * FROM notifications").count == 0{
                 NotificationsView.getNotificationFromSserver(notificationObj: nil)
            }
            
            self.emailTextField.text = ""
            
            self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "title.log_out").uppercased()
            recoveryButton.setTitle(Vocabulary.getWordFromKey(key: "title.log_out").uppercased(), for: .normal)
            
            self.backgroudImageView.addSubview(self.logInInformation)
            self.backgroudImageView.addSubview(recoveryButton)
            
            logInInformation.topAnchor.constraint(equalTo: self.customNavigationImageView.bottomAnchor, constant: DeviceType.isIpad() ? 60 : 30).isActive = true
            logInInformation.heightAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 150 : 100).isActive = true
            logInInformation.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            logInInformation.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant:padding).isActive = true
            
            recoveryButton.topAnchor.constraint(equalTo: logInInformation.bottomAnchor, constant: DeviceType.isIpad() ? 60 : 30).isActive = true
            recoveryButton.heightAnchor.constraint(equalToConstant: heightOftextField).isActive = true
            recoveryButton.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant:-padding).isActive = true
            recoveryButton.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant: padding).isActive = true
       
       
        
            if let userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject],let email = userDetails["Email"] as? String{
               
                let lbl1 = Vocabulary.getWordFromKey(key: "register_and_login.popup.loged_in_as").uppercased()
                let lbl2 = email
                let lbl3:String?
               
                
                
                if let groupCode = userDetails["groupCode"] as? String{
                    lbl3 = "(\( Vocabulary.getWordFromKey(key: "general_group").capitalized): \(groupCode))"
                }else{
                    
                    if String.getSelectedLanguage() == "2"{
                        lbl3 = "(Grupp - ej tillgängligt)"
                    }else{
                        lbl3 = "(Group: N/A)"
                    }
                }
                
                
                let mainString = lbl1+"\n\n"+lbl2+"\n\n"+lbl3!
                let attributedText = NSMutableAttributedString(string:mainString)
                
                let attributesOfLbl1 = [NSAttributedStringKey.font:UIFont.systemFont(ofSize:14, weight: UIFont.Weight(rawValue: 0)),NSAttributedStringKey.foregroundColor:UIColor.getThemeTextColor()]
                let rangeOfLbl1 = NSString(string: mainString).range(of: lbl1)
                attributedText.addAttributes(attributesOfLbl1, range: rangeOfLbl1)
                
                let attributesOfLbl2 = [NSAttributedStringKey.font:UIFont.systemFont(ofSize:13, weight: UIFont.Weight(rawValue: 0)),NSAttributedStringKey.foregroundColor:UIColor.getThemeTextColor()]
                let rangeOfLbl2 = NSString(string: mainString).range(of: lbl2)
                attributedText.addAttributes(attributesOfLbl2, range: rangeOfLbl2)
                
                let attributesOfLbl3 = [NSAttributedStringKey.font:UIFont.systemFont(ofSize:14, weight: UIFont.Weight(rawValue: 0)),NSAttributedStringKey.foregroundColor:UIColor.getThemeTextColor()]
                let rangeOfLbl3 = NSString(string: mainString).range(of: lbl3!)
                attributedText.addAttributes(attributesOfLbl3, range: rangeOfLbl3)
                logInInformation.attributedText = attributedText
            }
        }
        
       
    }
    
    @objc func handelButtonActionOfRegisterView(sender:UIButton){
        self.view.endEditing(true)
        switch sender.tag {
        case 10:
            GoogleAnalytics.setEvent(id: "login", title: "Login Button")
            self.doLogin()
            
        case 20: // button remember me
            
            GoogleAnalytics.setEvent(id: "remember_me", title: "Remeber Me Button")
            self.isRememberTrue = !self.isRememberTrue
            let unChecedImg =  UIImage(named: "unChecked")?.withRenderingMode(.alwaysTemplate)
            
            if var loginCredentials = UserDefaults.standard.object(forKey: "loginCredentials") as? [String:AnyObject]{
                loginCredentials["rememberMe"] = String(self.isRememberTrue) as AnyObject?
                UserDefaults.standard.set(loginCredentials, forKey: "loginCredentials")
                UserDefaults.standard.synchronize()
            }
            
            if self.isRememberTrue
            {   self.rememberMeImageView.image = UIImage(named: "checked")?.withRenderingMode(.alwaysTemplate)
            }else{
                self.rememberMeImageView.image = unChecedImg
            }
        case 30: //facebook login
            GoogleAnalytics.setEvent(id: "facebook_login", title: "Facebook Login Button")
            if !Reachability.isAvailable() {
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.no_connection"))
                return
            }
          
            let loginManager = LoginManager()
            loginManager.logIn([.email,.publicProfile,.userFriends], viewController: self, completion: { (result) in
                switch result {
                case .failed( _):
                    DispatchQueue.main.async{
                        ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
                    }
                case .success(_, _, let accessToken)://.success(let grantedPermissions, let declinedPermissions, let accessToken):
                    ShowHud.show()
                    FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(large)"]).start { (conn, result, err) in
                        if err != nil{
                            ShowToast.show(toatMessage: err!.localizedDescription)
                            return
                        }
                        if var fbDetails = result as? [String:AnyObject]{
                            fbDetails["auth"] = accessToken.authenticationToken as AnyObject?
                            self.facebookLoginManager(details: fbDetails)
                        }
                        else{
                            DispatchQueue.main.async{
                                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
                            }
                        }
                    }
                default:
                    break
                }
                
            })
            
            
        case 40:
            if currentViewType == .login{
                 GoogleAnalytics.setEvent(id: "create_account", title: "Create Account Button")
                self.currentViewType = .createAccount
                self.setUpBasicView()
            }else if currentViewType == .createAccount{
                 GoogleAnalytics.setEvent(id: "regiter", title: "Registration Button")
                self.doRegistration()
            }
        case 50:
            if currentViewType == .login{
                GoogleAnalytics.setEvent(id: "recover_password", title: "Recover Password Button")
                self.currentViewType = .recovery
                self.setUpBasicView()
            }else if currentViewType == .codeReceived{
                 GoogleAnalytics.setEvent(id: "send_new_recovery", title: "Send New Recovy Button")
                self.sendNewPassword()
            } else if currentViewType == .recovery{
                  GoogleAnalytics.setEvent(id: "send_recovery_to_server", title: "Send Recovy To Server Button")
                self.sendRecoveryCode()
            }else if currentViewType == .logout
            {
                 GoogleAnalytics.setEvent(id: "logout", title: "Logout Button")
                CustomAlerView.delegation = self
                CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "general_no").uppercased(),Vocabulary.getWordFromKey(key: "general_yes").uppercased()], titleMsg: Vocabulary.getWordFromKey(key: "title.log_out").uppercased(), desciption: Vocabulary.getWordFromKey(key: "register_and_login.popup.logout").capitalizingFirstLetter(),userInfo: nil)
            }
        case 60:
            if currentViewType == .recovery{
                GoogleAnalytics.setEvent(id: "code_received", title: "Code Recieved Button")
                self.currentViewType = .codeReceived
                self.setUpBasicView()
            }
        default:
            break
        }
    }
    
    override func backButtonActionHandeler(){
        if currentViewType == .createAccount || currentViewType == .recovery{
            self.currentViewType = .login
            self.setUpBasicView()
            return
        }else if currentViewType == .codeReceived{
            self.currentViewType = .recovery
            self.setUpBasicView()
            return
        }
        self.popToHomeView()
    }
    
    func doLogin(){
        let emailCount = self.emailTextField.text?.removeWhiteSpaces().count
        let passCount = self.passwordTextField.text?.removeWhiteSpaces().count
        if emailCount == 0 && passCount == 0{
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "register_and_login.label.enter_email_pass"))
        }
        else if emailCount == 0 {
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "register_and_login.label.enter_email") )
        }
        else if !(emailTextField.text!.trim().isEmail){
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "register_and_login.invalid_email"))
        }
        else if passCount! == 0 || passCount! < 4 {
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "register_and_login.enter_password"))
        }
        else{
            
            let param = ["Username":self.emailTextField.text?.removeWhiteSpaces().trim(),"Password":self.passwordTextField.text!,"LanguageId":String.getSelectedLanguage(),"DeviceId":String.get_device_token(),"DeviceType":"IPHONE"]
            ApiRequst.doRequest(requestType: .POST, queryString: "login", parameter: param as [String : AnyObject]) { (json) in
                
                DispatchQueue.main.async{
                    if var userInfo = json["Audience"] as? [String:AnyObject]{
                        
                        userInfo = userInfo.nullsRemoved
                        if let token = json["AccessToken"] as? String{
                            userInfo["AccessToken"] = token as AnyObject?
                        }
                        
                        if let groupCodeId = userInfo["MemberCode"] as? Int{
                            if let groupCode = userInfo["GroupName"] as? String,groupCode.removeWhiteSpaces().count != 0{
                                userInfo["groupCode"] = groupCode as AnyObject?
                            }
                            userInfo["memberCodeId"] = groupCodeId as AnyObject?
                        }
                        
                        let loginDetailsObject = ["rememberMe":String(self.isRememberTrue),"email":self.emailTextField.text?.trim(),"pass":self.passwordTextField.text?.trim()]
                       
                        UserDefaults.standard.set(loginDetailsObject, forKey: "loginCredentials")
                        UserDefaults.standard.set(userInfo.nullsRemoved, forKey: "userDetails")
                       
                        if let statics = userInfo["Statistics"] as? Int{
                            UserDefaults.standard.set(["totalReward":0,"currentProgress":statics], forKey: "innerCircleStatus")
                        }
                        
                        
                        
                        if let langId = userInfo["LanguageId"] as? Int{
                            UserDefaults.standard.set(String(langId), forKey: "selectedLanguageCode")
                        }
                        UserDefaults.standard.synchronize()
                      
                        self.currentViewType = .logout
                        ShowHud.show()
                        HomeViewController.getUpdateOfGroup(completionHandler: { (Bool) in
                            DispatchQueue.main.async(execute: {
                                ShowHud.hide()
                                RegisterAndLoginView.sendSubscriptionStatusToServer()
                            })
                        })
                        
                        self.setUpBasicView()
                        
                    }else{
                        DispatchQueue.main.async{
                            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
                        }
                    }
                }
                
            }
            
        }
    }
    func facebookLoginManager(details:[String:AnyObject]){
     
        
        if let token = details["auth"] as? String,let email = details["email"] as? String,let name = details["name"] as? String{
       
           
            func login(base64:String = "",imageData:Data?){
                let param = ["Name":name,"Username":email,"Password":"","OAuthId":token,"OAuthType":"Facebook","LanguageId":String.getSelectedLanguage(),"DeviceId":String.get_device_token(),"DeviceType":"IPHONE","Base64ProfilePicture":base64]
                ApiRequst.doRequest(requestType: .POST, queryString: "register", parameter: param as [String : AnyObject]) { (json) in
                    
                    DispatchQueue.main.async{
                        if var userInfo = json["Audience"] as? [String:AnyObject]{
                            
                            
                            userInfo = userInfo.nullsRemoved
                            if let token = json["AccessToken"] as? String{
                                userInfo["AccessToken"] = token as AnyObject?
                            }
                            
                            if let groupCodeId = userInfo["MemberCode"] as? Int{
                                if let groupCode = userInfo["GroupName"] as? String,groupCode.removeWhiteSpaces().count != 0{
                                    userInfo["groupCode"] = groupCode as AnyObject?
                                }
                                userInfo["memberCodeId"] = groupCodeId as AnyObject?
                            }
                            
                            if let token = json["AccessToken"] as? String{
                                userInfo["AccessToken"] = token as AnyObject?
                            }
                            
                            if imageData != nil{
                                    userInfo["profileImageViewData"] = imageData! as AnyObject?
                            }
                            
                            
                            if let statics = userInfo["Statistics"] as? Int{
                               
                                UserDefaults.standard.set(["totalReward":0,"currentProgress":statics], forKey: "innerCircleStatus")
                            }
                            
                            
                            UserDefaults.standard.set(userInfo.nullsRemoved, forKey: "userDetails")
                            UserDefaults.standard.removeObject(forKey: "loginCredentials")
                            UserDefaults.standard.set(true, forKey: "isLoggedInThroughFB")
                            
                            self.currentViewType = .logout
                            ShowHud.show()
                            HomeViewController.getUpdateOfGroup(completionHandler: { (Bool) in
                                DispatchQueue.main.async(execute: {
                                    ShowHud.hide()
                                    RegisterAndLoginView.sendSubscriptionStatusToServer()
                                })
                            })
                            
                            self.setUpBasicView()
                            
                        }else{
                                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
                            
                        }
                    }
                }
            }
            
            if UserDefaults.standard.object(forKey: "isLoggedInThroughFB") == nil{
                if let picture = details["picture"] as? [String:AnyObject],let dataDic = picture["data"] as? [String:AnyObject],let urlString1 = dataDic["url"] as? String{
                    
                    if let urlOfProfileImage = URL(string: urlString1){
                        let task = URLSession.shared.dataTask(with: urlOfProfileImage) { data, response, error in
                            guard let dataOfImage = data, error == nil else { return }
                            DispatchQueue.main.sync() {
                                let strBase64 = dataOfImage.base64EncodedString(options: .lineLength64Characters)
                                login(base64: strBase64, imageData: dataOfImage)
                                return
                                
                            }
                            login(imageData: nil)
                        }
                        task.resume()
                        
                        return
                    }
                }
            }
            
           
            login(imageData: nil)
            
        }else{
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "register_and_login.label.fb_data_err") )
        }
    }
    func doRegistration(){
        
        GoogleAnalytics.setEvent(id: "doRegistration", title: "Register button")
        
        let nameCount = self.aliasNameTextfield.text?.removeWhiteSpaces().count
        let emailCount = self.emailTextField.text?.removeWhiteSpaces().count
        let passCount = self.passwordTextField.text?.removeWhiteSpaces().count
        let confirmPass = self.confirmPasswordTextField.text?.removeWhiteSpaces().count
        
        if nameCount == 0 && emailCount == 0 && passCount == 0 && confirmPass == 0{
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "register_and_login.all_field_compolsury"))
        }
        else if nameCount == 0{
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "general.textfield.enter_name") )
        }
        else if emailCount == 0 {
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "register_and_login.label.enter_email") )
        }
        else if !(emailTextField.text!.trim().isEmail){
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "register_and_login.invalid_email"))
        }
        else if passCount! == 0 || passCount! < 4 {
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "register_and_login.enter_password"))
        }
        else if passwordTextField.text != confirmPasswordTextField.text {
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "register_and_login.password_mismatch"))
        }
        else{
            
            let param = ["Username":self.emailTextField.text!.removeWhiteSpaces().trim(),"Password":self.passwordTextField.text!,"Name":aliasNameTextfield.text!.trim(),"LanguageId":String.getSelectedLanguage(),"DeviceId":String.get_device_token(),"DeviceType":"IPHONE"]
            ApiRequst.doRequest(requestType: .POST, queryString: "register", parameter: param as [String : AnyObject]) { (json) in
                
                DispatchQueue.main.async{
                    if var userInfo = json["Audience"] as? [String:AnyObject]{
                        
                        userInfo = userInfo.nullsRemoved
                        if let token = json["AccessToken"] as? String{
                            userInfo["AccessToken"] = token as AnyObject?
                        }
                        
                        UserDefaults.standard.set(userInfo.nullsRemoved, forKey: "userDetails")
                        UserDefaults.standard.synchronize()
                      
                        self.currentViewType = .logout
                        self.setUpBasicView()
                        RegisterAndLoginView.sendSubscriptionStatusToServer()
                        
                        
                        if let msg = json["Message"] as? String,msg.removeWhiteSpaces().count != 0{
                            ShowToast.show(toatMessage: msg)
                        }
                        
                    }else{
                        DispatchQueue.main.async{
                            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
                        }
                    }
                }
            }
        }
    }
    
    func logout(){
        
        if let userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject],let accessToken = userDetails["AccessToken"] as? String, let userId = userDetails["Id"]{
           
            ApiRequst.doRequest(requestType: .DELETE, queryString: "logout/users/\(userId)/\(accessToken)", parameter: nil,showHUD: false) { (json) in
                if let msg = json["Message"] as? String,msg.removeWhiteSpaces().count != 0{
                    DispatchQueue.main.async(execute: {
                        ShowToast.show(toatMessage: msg)
                    })
                }
            }
        }
      
        self.currentViewType = .login
        self.setUpBasicView()
    }
    
    
    func sendNewPassword(){
        let emailCount = self.emailTextField.text?.removeWhiteSpaces().count
        let recCode = self.recoveryCodeTextfield.text?.removeWhiteSpaces().count
        let passCount = self.passwordTextField.text?.removeWhiteSpaces().count
        let confirmPass = self.confirmPasswordTextField.text?.removeWhiteSpaces().count
        
        if recCode == 0 && emailCount == 0 && passCount == 0 && confirmPass == 0{
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "register_and_login.all_field_compolsury"))
        }
        else if emailCount == 0 {
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "register_and_login.label.enter_email") )
        }
        else if !(emailTextField.text!.trim().isEmail){
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "register_and_login.invalid_email"))
        }
        else if recCode == 0{
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "register_and_login.label.enter_recovery_code"))
        }
        else if passCount! == 0 || passCount! < 4  {
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "register_and_login.enter_password"))
        }
        else if passwordTextField.text != confirmPasswordTextField.text {
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "register_and_login.password_mismatch"))
        }
        else{
            let params = ["RecoveryCode":self.recoveryCodeTextfield.text!.removeWhiteSpaces(),"Email":self.emailTextField.text!.removeWhiteSpaces().trim(),"NewPassword":self.passwordTextField.text!]
            ApiRequst.doRequest(requestType: .PUT, queryString: "changepassword", parameter:params as [String : AnyObject]?) { (json) in
                DispatchQueue.main.async{
                    DispatchQueue.main.async{
                        
                        if let msg = json["Message"] as? String,msg.removeWhiteSpaces().count != 0{
                            ShowToast.show(toatMessage: msg)
                        }else{
                             ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "register_and_login.label.password_changed"))
                        }
                        self.currentViewType = .login
                        self.setUpBasicView()
                    }
                }
            }
        }
    }
    func sendRecoveryCode(){
        
        if self.emailTextField.text?.count == 0{
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "register_and_login.label.enter_email") )
        } else if !(emailTextField.text!.trim().isEmail){
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "register_and_login.invalid_email"))
        } else
        {
            // go ahead
            ApiRequst.doRequest(requestType: .POST, queryString: "recovery", parameter:["Email":self.emailTextField.text!.removeWhiteSpaces().trim() as AnyObject]) { (json) in
                DispatchQueue.main.async{
                    DispatchQueue.main.async{
                        if let msg = json["Message"] as? String,msg.removeWhiteSpaces().count != 0{
                            ShowToast.show(toatMessage: msg)
                        }else{
                             ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "register_and_login.recover_code_sent"))
                        }
                        
                       
                        self.currentViewType = .codeReceived
                        self.setUpBasicView()
                    }
                }
            }
            
        }
    }
    
    
    //MARK: TextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.currentViewType == .login{
            
            if textField == emailTextField{
                passwordTextField.becomeFirstResponder()
            } else if textField == passwordTextField{
                self.view.endEditing(true)
            }
            
        }else if self.currentViewType == .createAccount{
            
            if textField == aliasNameTextfield{
                emailTextField.becomeFirstResponder()
            } else if textField == emailTextField{
                passwordTextField.becomeFirstResponder()
            } else if textField == passwordTextField{
                confirmPasswordTextField.becomeFirstResponder()
            }else if textField == confirmPasswordTextField{
                self.view.endEditing(true)
            }
            
        }else if self.currentViewType == .recovery{
            
            self.view.endEditing(true)
            
        }else if self.currentViewType == .codeReceived{
            
            if textField == emailTextField{
                recoveryCodeTextfield.becomeFirstResponder()
            } else if textField == recoveryCodeTextfield{
                passwordTextField.becomeFirstResponder()
            } else if textField == passwordTextField{
                confirmPasswordTextField.becomeFirstResponder()
            }else if textField == confirmPasswordTextField{
                self.view.endEditing(true)
            }
            
        }
        return true
    }
    
   
    //MARK: Custom alert view delegation 
    func didTappedCustomAletButton(selectedIndex:Int,title: String,userInfo:[String:AnyObject]?) {
        if selectedIndex == 1{
            self.logout()
        }
    }
    
    
    
    class func sendSubscriptionStatusToServer(){
        if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
            ApiRequst.doRequest(requestType: .PUT, queryString: "users/\(userId)/updateusersubscription/\(String.has_full_access())", parameter: nil,showHUD: false, completionHandler: { (response) in
                print(response)
            })
        }
        
    }
}












