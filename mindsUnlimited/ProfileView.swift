//
//  ProfileView.swift
//  mindsUnlimited
//
//  Created by IPS on 08/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit


class ProfileView:GeneralViewController,UITextFieldDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //MARK: Class properties
    var cameFromGroupView = false
    var isKeyboardOpen = false
    var hasChangesImage = false
    var isUserImageExist = false
    var imagePicker = UIImagePickerController()
    lazy var profleImageView:UIImageView={
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        iv.image = #imageLiteral(resourceName: "camera_placeholder")
        iv.contentMode = .center
        iv.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedOnProfileImage))
        iv.addGestureRecognizer(tap)
        return iv
    }()
    
    lazy var aliasNameTextfield:CustomTextField={
        let txt = CustomTextField()
        txt.delegate = self
        txt.translatesAutoresizingMaskIntoConstraints = false
        txt.placeholder = Vocabulary.getWordFromKey(key: "general.title.name_alias").uppercased()+" *"
        txt.textAlignment = .center
        txt.textColor = UIColor.getThemeTextColor()
        txt.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 17 : 15)
        return txt
    }()
    
    lazy var additionalTextView:UITextView={
        let txt = UITextView()
        txt.delegate = self
        txt.translatesAutoresizingMaskIntoConstraints = false
        txt.backgroundColor = .white
        txt.textAlignment = .left
        txt.layer.cornerRadius = 15
        txt.layer.masksToBounds = true
        txt.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 17 : 15)
        txt.text = Vocabulary.getWordFromKey(key: "profile.textview.enter.additional_info")
        txt.textColor = .lightGray
        txt.showShadow()
        return txt
    }()
    
    
    let showMainLabel:UILabel={
        let label = UILabel()
        label.text =  Vocabulary.getWordFromKey(key: "profileview.show_mail").uppercased()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getThemeTextColor()
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : 16)
        return label
    }()
    

    lazy var showMailSwitch:UISwitch={
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.thumbTintColor = .white
        sw.onTintColor = UIColor.switchColor()
        sw.backgroundColor = .gray
        sw.layer.cornerRadius = 18
        sw.isOn = true
        sw.addTarget(self, action: #selector(switchAction), for: .valueChanged)
        return sw
    }()
    
    
    lazy var saveButton:UIButton={
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle(Vocabulary.getWordFromKey(key: "profile.button.title.saved").uppercased(), for: .normal)
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 24 : 20, weight: UIFont.Weight(rawValue: 0))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 7
        button.addTarget(self, action: #selector(self.buttonSaveActionHandler), for: .touchUpInside)
        button.showShadow()
        return button
    }()
    
    
    
    
    
    //MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "title.profile").uppercased()
        
       
        DispatchQueue.global(qos: .background).sync {
             self.setUpViews()
        }
       
    }
    
    
   
    
    //MARK: Textview and textfield delegates 
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
     
        if !isKeyboardOpen {
            isKeyboardOpen = true
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isKeyboardOpen = false
        saveButton.setTitle(Vocabulary.getWordFromKey(key: "profile.button.title.save").uppercased(), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
   
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
       
        if isKeyboardOpen{
            return false
        }
        
        if textView.text.lowercased() == Vocabulary.getWordFromKey(key: "profile.textview.enter.additional_info").lowercased()
        {
            textView.textColor = UIColor.getThemeTextColor()
            textView.text = ""
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.removeWhiteSpaces().replacingOccurrences(of: "\n", with: "").count == 0{
            textView.text =  Vocabulary.getWordFromKey(key: "profile.textview.enter.additional_info")
            textView.textColor = .lightGray
        }
         saveButton.setTitle(Vocabulary.getWordFromKey(key: "profile.button.title.save").uppercased(), for: .normal)
        
        isKeyboardOpen = false
    }
    
    //MARK: Other methods
    
    @objc func switchAction(){
        
        
        GoogleAnalytics.setEvent(id: "show_email_switch", title: "Show-Email Switch")
        
         saveButton.setTitle(Vocabulary.getWordFromKey(key: "profile.button.title.save").uppercased(), for: .normal)
    }
    
    func setUpViews(){
        
        let paddingForiPhone:CGFloat = Int(UIScreen.main.bounds.width) > 320 ? 40 : 15
       
        let padding:CGFloat =  DeviceType.isIpad() ? 100 : paddingForiPhone
    
      
     
        var sizeOfImageView:CGFloat = DeviceType.isIpad() ? 330 : UIScreen.main.bounds.height/3.2
        
        var spaceBetween:CGFloat = DeviceType.isIpad() ? 35 : 25
        if UIScreen.main.bounds.height < 481{
            sizeOfImageView = 140
            spaceBetween = 10
        }
        
        self.backgroudImageView.addSubview(profleImageView)
        self.profleImageView.heightAnchor.constraint(equalToConstant: sizeOfImageView).isActive = true
        self.profleImageView.widthAnchor.constraint(equalToConstant: sizeOfImageView).isActive = true
        self.profleImageView.centerXAnchor.constraint(equalTo: self.backgroudImageView.centerXAnchor).isActive = true
        self.profleImageView.topAnchor.constraint(equalTo: self.customNavigationImageView.bottomAnchor, constant: 20).isActive = true
       
        
        self.backgroudImageView.addSubview(aliasNameTextfield)
        self.aliasNameTextfield.heightAnchor.constraint(equalToConstant:DeviceType.isIpad() ? 55 : 40).isActive = true
        self.aliasNameTextfield.topAnchor.constraint(equalTo: self.profleImageView.bottomAnchor, constant: spaceBetween).isActive = true
        self.aliasNameTextfield.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant: -padding).isActive = true
        self.aliasNameTextfield.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant: padding).isActive = true
        
        
        let showMailConfigView:UIView={
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .clear
            return view
        }()
        
        self.backgroudImageView.addSubview(showMailConfigView)
        showMailConfigView.heightAnchor.constraint(equalToConstant:DeviceType.isIpad() ? 55 : 40).isActive = true
        showMailConfigView.topAnchor.constraint(equalTo: self.aliasNameTextfield.bottomAnchor, constant: spaceBetween-10).isActive = true
        showMailConfigView.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant: -padding).isActive = true
        showMailConfigView.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant: padding).isActive = true
        
     
        
        
        showMailConfigView.addSubview(showMainLabel)
        showMainLabel.leftAnchor.constraint(equalTo: showMailConfigView.leftAnchor, constant: 0).isActive = true
        showMainLabel.centerYAnchor.constraint(equalTo: showMailConfigView.centerYAnchor, constant: 0).isActive = true
        
        showMailConfigView.addSubview(showMailSwitch)
        showMailSwitch.rightAnchor.constraint(equalTo: showMailConfigView.rightAnchor, constant: 0).isActive = true
        showMailSwitch.centerYAnchor.constraint(equalTo: showMailConfigView.centerYAnchor, constant: 0).isActive = true
        
        self.backgroudImageView.addSubview(additionalTextView)
        self.additionalTextView.heightAnchor.constraint(equalToConstant: sizeOfImageView/2).isActive = true
        self.additionalTextView.topAnchor.constraint(equalTo: showMailConfigView.bottomAnchor, constant: 20).isActive = true
        self.additionalTextView.rightAnchor.constraint(equalTo: self.backgroudImageView.rightAnchor, constant: -padding).isActive = true
        self.additionalTextView.leftAnchor.constraint(equalTo: self.backgroudImageView.leftAnchor, constant: padding).isActive = true
        
        self.backgroudImageView.addSubview(saveButton)
        self.saveButton.heightAnchor.constraint(equalToConstant:DeviceType.isIpad() ? 45 : 35).isActive = true
        self.saveButton.widthAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 130 : 100).isActive = true
        self.saveButton.centerXAnchor.constraint(equalTo: self.backgroudImageView.centerXAnchor).isActive = true
        self.saveButton.topAnchor.constraint(equalTo: additionalTextView.bottomAnchor, constant: 25).isActive = true
        
        self.setProfileImageAndFields()
        
    }
    
    func setProfileImageAndFields(){
       
        if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
            func set(){
                
                if let picUrl = userDetails["profileImageViewData"] as? String,picUrl.removeWhiteSpaces().count != 0{
                    if let url = URL(string: picUrl){
                        
                         let loadingIndicator:UIActivityIndicatorView={
                            let loading = UIActivityIndicatorView()
                            loading.translatesAutoresizingMaskIntoConstraints = false
                            loading.activityIndicatorViewStyle = .white
                            loading.backgroundColor = UIColor.init(white: 0.5, alpha: 0.7)
                            loading.layer.cornerRadius = 8
                            loading.layer.masksToBounds = true
                            return loading
                        }()
                     
                        loadingIndicator.startAnimating()
                        
                        self.profleImageView.isUserInteractionEnabled = false
                        self.profleImageView.addSubview(loadingIndicator)
                        loadingIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
                        loadingIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
                        loadingIndicator.centerXAnchor.constraint(equalTo: self.profleImageView.centerXAnchor).isActive = true
                        loadingIndicator.centerYAnchor.constraint(equalTo: self.profleImageView.centerYAnchor).isActive = true
                        
                       
                        let task = URLSession.shared.dataTask(with: url) { data, response, error in
                            guard let data = data, error == nil else { return }
                            
                            DispatchQueue.main.sync() {
                                
                                userDetails["profileImageViewData"] = data as AnyObject?
                                UserDefaults.standard.set(userDetails.nullsRemoved, forKey: "userDetails")
                                self.profleImageView.image = UIImage(data: data)
                                self.isUserImageExist = true
                                self.profleImageView.contentMode = .scaleToFill
                                
                                loadingIndicator.stopAnimating()
                                loadingIndicator.removeFromSuperview()
                                self.profleImageView.isUserInteractionEnabled = true
                            }
                        }
                        task.resume()
                    }
                }else if let imageData = userDetails["profileImageViewData"] as? Data{
                    self.profleImageView.image = UIImage(data: imageData)
                    self.profleImageView.contentMode = .scaleToFill
                    self.isUserImageExist = true
                }
                
                if let name = userDetails["Name"] as? String,name.removeWhiteSpaces().count != 0{
                    self.aliasNameTextfield.text = name
                }
                if let isOn = userDetails["ShowEmail"]{
                    if String(describing: isOn).lowercased().removeWhiteSpaces() == "1" || String(describing: isOn).lowercased().removeWhiteSpaces() == "true"{
                         self.showMailSwitch.isOn  = true
                    }else{
                         self.showMailSwitch.isOn  = false
                    }
                }
                
                if let addInfo = userDetails["AdditionalInformation"] as? String,addInfo.removeWhiteSpaces().count != 0{
                    self.additionalTextView.text = addInfo
                    self.additionalTextView.textColor = UIColor.getThemeTextColor()
                }
            }
            
            if Reachability.isAvailable(){
                let queryString = "/users/\(userId)/profiledetail"
                ApiRequst.doRequest(requestType: .GET, queryString: queryString, parameter: nil, completionHandler: { (json) in
                    
                    if let userProfile = json["UserProfile"] as? [String:AnyObject]{
                       
                        if let addtionalInfo = userProfile["AdditionalInformation"] as? String{
                            userDetails["AdditionalInformation"] = addtionalInfo as AnyObject?
                        }
                        if let name = userProfile["Name"] as? String{
                            userDetails["Name"] = name as AnyObject?
                        }
                        userDetails["profileImageViewData"] = nil
                        if let photoUrl = userProfile["PhotoUrl"] as? String,photoUrl.removeWhiteSpaces().count != 0{
                            userDetails["profileImageViewData"] = photoUrl as AnyObject?
                        }
                        if let showEmail = userProfile["ShowEmail"]{
                            userDetails["ShowEmail"] = String(describing: showEmail) as AnyObject?
                        }
                        UserDefaults.standard.set(userDetails.nullsRemoved, forKey: "userDetails")
                   
                    }
                    DispatchQueue.main.async(execute: {
                        set()
                    })
                })
            }else{
                set()
            }
            
        }
        
   
    }
    
    
    
    override func backButtonActionHandeler(){
        if self.cameFromGroupView{
            self.navigationController!.popViewController(animated: true)
        }else{
            self.popToHomeView()
        }
    }
    
    
    @objc func buttonSaveActionHandler(){
        GoogleAnalytics.setEvent(id: "save_profile", title: "Save Profile Details Button")
        saveButton.setTitle(Vocabulary.getWordFromKey(key: "profile.button.title.saved").uppercased(), for: .normal)
        self.view.endEditing(true)
        
        if aliasNameTextfield.text?.removeWhiteSpaces().count != 0{
            if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
          
               let queryString = "/users/\(userId)/profile"
                
                var param = [String:String]()
                
                param["Name"] = aliasNameTextfield.text!
                if showMailSwitch.isOn{
                     param["ShowEmail"] = "true"
                }else{
                  param["ShowEmail"] = "false"
                }
                if additionalTextView.text.lowercased() != Vocabulary.getWordFromKey(key: "profile.textview.enter.additional_info").lowercased(){
                    param["AdditionalInformation"] = additionalTextView.text!
               
                }
               
                
                if hasChangesImage{
                    
                    param["IsUpdate"]  = "true"
                    if isUserImageExist{
                        
                        if let image = profleImageView.image,let imageData = UIImageJPEGRepresentation(image, 0.5){
                            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                            param["Base64ProfilePicture"] = strBase64
                        }
                        
                    }else{
                        
                        param["Base64ProfilePicture"] = ""
                    }
                }else{
                    param["IsUpdate"]  = "false"
                    param["Base64ProfilePicture"] = ""
                }
               
              
                ApiRequst.doRequest(requestType: .PUT, queryString: queryString, parameter:param as [String : AnyObject]? , completionHandler: { (json) in
                    
                    DispatchQueue.main.async{
                        
                        if !self.isUserImageExist{
                            userDetails["profileImageViewData"] = nil
                        }else{
                            if let image = self.profleImageView.image,let imageData = UIImagePNGRepresentation(image){
                                userDetails["profileImageViewData"] = imageData as AnyObject?
                            }
                        }
                     
                        userDetails["Name"] = self.aliasNameTextfield.text! as AnyObject?
                        userDetails["ShowEmail"] = self.showMailSwitch.isOn as AnyObject?
                        userDetails["AdditionalInformation"] = self.additionalTextView.text! as AnyObject?
                        
                        UserDefaults.standard.set(userDetails.nullsRemoved, forKey: "userDetails")
                       
                        ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "profileview.profile_saved"))
                        
                        if self.cameFromGroupView{
                            self.navigationController!.popViewController(animated: true)
                        }
                        
                    }
                })
            
            }
        
        }else{
             ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key: "general.textfield.enter_name") )
        }
        
    }
    @objc func tappedOnProfileImage(){
       
        GoogleAnalytics.setEvent(id: "tappedOnProfileImage", title: "Change Profile Image")
        func openGalary(isCamera:Bool = false){
            
            if UIImagePickerController.isSourceTypeAvailable(!isCamera ? .savedPhotosAlbum : .camera){
                
                imagePicker.delegate = self
                imagePicker.sourceType = !isCamera ? .savedPhotosAlbum : .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
      
        
        let actionSheetController = UIAlertController(title: Vocabulary.getWordFromKey(key: "profileview.profile_image").uppercased(), message: "\(Vocabulary.getWordFromKey(key: "profile.popup.select_option"))".capitalized, preferredStyle: .actionSheet)
        
        
        let cemeraActionButton = UIAlertAction(title: Vocabulary.getWordFromKey(key: "profile.popup.option.capture").capitalized, style: .default) { action -> Void in
            
            openGalary(isCamera: true)
        }
        
        let galaryActionButton = UIAlertAction(title: Vocabulary.getWordFromKey(key: "profile.popup.pick_from_album").capitalized, style: .default) { action -> Void in
            openGalary()
        }
        
        let removeActionButton = UIAlertAction(title: Vocabulary.getWordFromKey(key: "general.remove").capitalized, style: .default) { action -> Void in
           
            if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let _ = userDetails["groupCode"]{
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "profile.popup.can_not_remove_image"))
            }else{
                self.hasChangesImage = true
                self.profleImageView.image = #imageLiteral(resourceName: "camera_placeholder")
                self.isUserImageExist = false
                self.profleImageView.contentMode = .center
                self.saveButton.setTitle(Vocabulary.getWordFromKey(key: "profile.button.title.save").uppercased(), for: .normal)
            }
        }
        
        let cancelActionButton = UIAlertAction(title: Vocabulary.getWordFromKey(key: "general.cancel").capitalized, style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cemeraActionButton)
        actionSheetController.addAction(galaryActionButton)
        if self.isUserImageExist{
               actionSheetController.addAction(removeActionButton)
        }
        actionSheetController.addAction(cancelActionButton)
        
        if DeviceType.isIpad(){
            actionSheetController.modalPresentationStyle = .popover
            if let presenter = actionSheetController.popoverPresentationController{
                presenter.sourceView = self.view
                presenter.permittedArrowDirections = .init(rawValue: 0)
                presenter.sourceRect = CGRect(x: (self.view.frame.width/2)-100, y: (self.view.frame.height/2)-250, width: 200, height: 500)
            }
        }
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
 
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        saveButton.setTitle(Vocabulary.getWordFromKey(key: "profile.button.title.save").uppercased(), for: .normal)
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        profleImageView.image = chosenImage
        profleImageView.contentMode = .scaleToFill
        isUserImageExist = true
        self.hasChangesImage = true
        dismiss(animated:true, completion: nil)
    }
    
    

    
    
}
