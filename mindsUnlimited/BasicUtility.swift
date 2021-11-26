

import UIKit
import SystemConfiguration
class ShowToast: NSObject {
    static var lastToastLabelReference:UILabel?
    static var initialYPos:CGFloat = 0
    class func show(toatMessage:String)
    {
        
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window
        {
            ShowHud.hide()
            if lastToastLabelReference != nil
            {
                let prevMessage = lastToastLabelReference!.text?.replacingOccurrences(of: " ", with: "").lowercased()
                let currentMessage = toatMessage.replacingOccurrences(of: " ", with: "").lowercased()
                if prevMessage == currentMessage
                {
                    return
                }
            }
            
            let cornerRadious:CGFloat = 12
            let toastContainerView:UIView={
                let view = UIView()
                view.layer.cornerRadius = cornerRadious
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = UIColor.rgb(129, green: 206, blue: 214)
                view.alpha = 1
                return view
            }()
            let labelForMessage:UILabel={
                let label = UILabel()
                label.layer.cornerRadius = cornerRadious
                label.layer.masksToBounds = true
                label.textAlignment = .center
                label.numberOfLines = 0
                label.adjustsFontSizeToFitWidth = true
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = toatMessage
                label.textColor = .white
                label.backgroundColor = UIColor.init(white: 0, alpha: 0)
                return label
            }()
            
            keyWindow.addSubview(toastContainerView)
            
            let fontType = UIFont.boldSystemFont(ofSize: DeviceType.isIpad() ? 14 : 12)
            labelForMessage.font = fontType
            
            let sizeOfMessage = NSString(string: toatMessage).boundingRect(with: CGSize(width: keyWindow.frame.width, height: keyWindow.frame.height), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font:fontType], context: nil)
            
            let topAnchor = toastContainerView.bottomAnchor.constraint(equalTo: keyWindow.topAnchor, constant: 0)
            keyWindow.addConstraint(topAnchor)
            
            toastContainerView.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor, constant: 0).isActive = true
            
            var extraHeight:CGFloat = 0
            if (keyWindow.frame.size.width) < (sizeOfMessage.width+20)
            {
                extraHeight = (sizeOfMessage.width+20) - (keyWindow.frame.size.width)
                toastContainerView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor, constant: 5).isActive = true
                toastContainerView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor, constant: -5).isActive = true
            }
            else
            {
                toastContainerView.widthAnchor.constraint(equalToConstant: sizeOfMessage.width+20).isActive = true
            }
            let totolHeight:CGFloat = sizeOfMessage.height+25+extraHeight
            toastContainerView.heightAnchor.constraint(equalToConstant:totolHeight).isActive = true
            toastContainerView.addSubview(labelForMessage)
            lastToastLabelReference = labelForMessage
            labelForMessage.topAnchor.constraint(equalTo: toastContainerView.topAnchor, constant: 0).isActive = true
            labelForMessage.bottomAnchor.constraint(equalTo: toastContainerView.bottomAnchor, constant: 0).isActive = true
            labelForMessage.leftAnchor.constraint(equalTo: toastContainerView.leftAnchor, constant: 5).isActive = true
            labelForMessage.rightAnchor.constraint(equalTo: toastContainerView.rightAnchor, constant: -5).isActive = true
            keyWindow.layoutIfNeeded()
            
            let padding:CGFloat = initialYPos == 0 ? (DeviceType.isIpad() ? 100 : 70) : 10 // starting position
            initialYPos += padding+totolHeight
            topAnchor.constant = initialYPos
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
                keyWindow.layoutIfNeeded()
            }, completion: { (bool) in
                
                topAnchor.constant = 0
                UIView.animate(withDuration: 0.4, delay: 3, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
                    keyWindow.layoutIfNeeded()
                }, completion: { (bool) in
                    if let lastToastShown = lastToastLabelReference,labelForMessage == lastToastShown
                    {
                       lastToastLabelReference = nil
                    }
                    initialYPos -= (padding+totolHeight)
                    toastContainerView.removeFromSuperview()
                })
            })
        }
    }
}
class ShowHud:NSObject
{
    static let disablerView:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.15)
        return view
    }()
    
    static let containerView:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = UIColor.init(white: 0.3, alpha: 0)
        return view
    }()
    static var loadingIndicator:UIActivityIndicatorView={
        let loading = UIActivityIndicatorView()
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.activityIndicatorViewStyle = .whiteLarge
        loading.backgroundColor = .clear
        loading.layer.cornerRadius = 16
        loading.layer.masksToBounds = true
        return loading
    }()
    static let loadingMsgLabel:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Vocabulary.getWordFromKey(key: "loading_hud_please_wait").capitalizingFirstLetter()
        label.textAlignment = .center
        let fontType = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 16 : 14)
        label.font = fontType
        label.textColor = .white
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.alpha = 0
        return label
    }()
    
    static var timerToHideHud:Timer?
    static var timerToShowHud:Timer?
    
    class func show(loadingMessage:String=Vocabulary.getWordFromKey(key: "loading_hud_please_wait").capitalizingFirstLetter())
    {
        ShowHud.timerToHideHud?.invalidate()
        UIApplication.shared.resignFirstResponder()
        
        ShowHud.timerToShowHud = Timer.scheduledTimer(timeInterval: 1, target: ShowHud.self, selector: #selector(ShowHud.showHudAfterOneSecond), userInfo: nil, repeats: false)
        
        
    }
    
    class func hide(){
        
        ShowHud.timerToShowHud?.invalidate()
        ShowHud.timerToHideHud = Timer.scheduledTimer(timeInterval: 1, target: ShowHud.self, selector: #selector(ShowHud.hideAfterOneSecond), userInfo: nil, repeats: false)
    }
    
    @objc class func hideAfterOneSecond(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        ShowHud.loadingIndicator.stopAnimating()
        ShowHud.disablerView.removeFromSuperview()
        timerToHideHud?.invalidate()
    }
    @objc class func showHudAfterOneSecond(){
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window
        {
            if !ShowHud.loadingIndicator.isAnimating
            {
              //  loadingMsgLabel.text = loadingMessage
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
                keyWindow.addSubview(disablerView)
                disablerView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor).isActive = true
                disablerView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor).isActive = true
                disablerView.topAnchor.constraint(equalTo: keyWindow.topAnchor).isActive = true
                disablerView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor).isActive = true
                ShowHud.loadingIndicator.startAnimating()
                
                disablerView.addSubview(containerView)
                
                containerView.centerXAnchor.constraint(equalTo: disablerView.centerXAnchor).isActive = true
                containerView.centerYAnchor.constraint(equalTo: disablerView.centerYAnchor).isActive = true
                let squareSize:CGFloat = DeviceType.isIpad() ? 160 : 140
                containerView.widthAnchor.constraint(equalToConstant: squareSize).isActive = true
                containerView.heightAnchor.constraint(equalToConstant: squareSize).isActive = true
                
                
                containerView.addSubview(loadingMsgLabel)
                loadingMsgLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor ,constant:-10).isActive = true
                loadingMsgLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor,constant:-6).isActive = true
                loadingMsgLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor,constant:6).isActive = true
                
                containerView.addSubview(loadingIndicator)
                loadingIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                loadingIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            }
            else
            {
              //  loadingMsgLabel.text = loadingMessage
            }
        }
    }
    
 }
protocol CustomPickerViewDelegate:class{
    
    func didTappedDoneButton(selectedValueForComponent1:String,selectedValueForComponent2:String,index1:Int,index2:Int)
}
class ShowPickerView: UIPickerView,UIPickerViewDelegate,UIPickerViewDataSource{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "picker_bg"))
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    static var pickerViewObj = ShowPickerView()
    var delegation:CustomPickerViewDelegate?
    lazy var pickerViewFontColor = UIColor.getThemeTextColor()
    lazy var topActionBar:CGFloat = (DeviceType.isIpad() ? 50 : 40);
    lazy var totalHeight:CGFloat = (DeviceType.isIpad() ? 150 : 130)+self.topActionBar;
    var dataSourceArrayForComponent1:[String]?
    var dataSourceArrayForComponent2:[String]?
    let containerView:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.4)
        return view
    }()
    
    let actionView:UIView={
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor =  UIColor.init(patternImage: #imageLiteral(resourceName: "picker_bg"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var cancelButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 20 : 18)
        button.backgroundColor = .clear
        button.setTitle(Vocabulary.getWordFromKey(key: "general.cancel").uppercased(), for:.normal)
        button.addTarget(self, action: #selector(self.cancelButtonAction), for: .touchUpInside)
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        return button
    }()
    
    lazy var doneButton:UIButton={
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 20 : 18)
        button.backgroundColor = .clear
        button.setTitle(Vocabulary.getWordFromKey(key: "general_ok").uppercased(), for:.normal)
        button.addTarget(self, action: #selector(self.doneButtonAction), for: .touchUpInside)
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        return button
    }()
    
    var prevouseSelectedIndexForComponent1:Int?
    var prevouseSelectedIndexForComponent2:Int?
    
    class func showPickerView(dataSouceForComponent1:[String],selectedValueForComponent1:String = "",dataSouceForComponent2:[String],selectedValueForComponent2:String = "")
    {
        //adding picker view
        if let keyWindow = UIApplication.shared.keyWindow
        {
            pickerViewObj =  ShowPickerView()
           
            keyWindow.addSubview(pickerViewObj.containerView)
            pickerViewObj.containerView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor, constant: 0).isActive = true
            pickerViewObj.containerView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor, constant: 0).isActive = true
            pickerViewObj.containerView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor).isActive = true
            pickerViewObj.containerView.topAnchor.constraint(equalTo: keyWindow.topAnchor).isActive = true
            
            pickerViewObj.dataSourceArrayForComponent1 = dataSouceForComponent1
            pickerViewObj.dataSourceArrayForComponent2 = dataSouceForComponent2
            
            for (index,value) in dataSouceForComponent1.enumerated()  {
                if value.lowercased().replacingOccurrences(of: " ", with: "") == selectedValueForComponent1.lowercased().replacingOccurrences(of: " ", with: "")
                {
                    pickerViewObj.selectRow(index, inComponent: 0, animated: true)
                    pickerViewObj.prevouseSelectedIndexForComponent1 = index
                    break
                }
            }
            
            for (index,value) in dataSouceForComponent2.enumerated(){
                if value.lowercased().replacingOccurrences(of: " ", with: "") == selectedValueForComponent2.lowercased().replacingOccurrences(of: " ", with: "")
                {
                    pickerViewObj.selectRow(index, inComponent: 1, animated: true)
                    pickerViewObj.prevouseSelectedIndexForComponent2 = index
                    break
                }
            }
            
            pickerViewObj.containerView.addSubview(pickerViewObj)
            
           
            pickerViewObj.heightAnchor.constraint(equalToConstant: pickerViewObj.totalHeight).isActive = true
            pickerViewObj.centerYAnchor.constraint(equalTo: pickerViewObj.containerView.centerYAnchor).isActive = true
            pickerViewObj.widthAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 320 : 310).isActive = true
            pickerViewObj.centerXAnchor.constraint(equalTo: pickerViewObj.containerView.centerXAnchor).isActive = true
            
            //adding top action sheet
            pickerViewObj.containerView.addSubview(pickerViewObj.actionView)
            pickerViewObj.actionView.rightAnchor.constraint(equalTo: pickerViewObj.rightAnchor, constant: 0).isActive = true
            pickerViewObj.actionView.heightAnchor.constraint(equalToConstant: pickerViewObj.topActionBar).isActive = true
            pickerViewObj.actionView.leftAnchor.constraint(equalTo: pickerViewObj.leftAnchor, constant: 0).isActive = true
            pickerViewObj.actionView.bottomAnchor.constraint(equalTo: pickerViewObj.topAnchor, constant: 22).isActive = true
            
            pickerViewObj.actionView.addSubview(pickerViewObj.cancelButton)
            pickerViewObj.actionView.addSubview(pickerViewObj.doneButton)
            
            pickerViewObj.cancelButton.topAnchor.constraint(equalTo: pickerViewObj.actionView.topAnchor).isActive = true
            pickerViewObj.cancelButton.bottomAnchor.constraint(equalTo: pickerViewObj.actionView.bottomAnchor).isActive = true
            pickerViewObj.cancelButton.leftAnchor.constraint(equalTo: pickerViewObj.actionView.leftAnchor, constant: 10).isActive = true
            pickerViewObj.cancelButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            
            pickerViewObj.doneButton.topAnchor.constraint(equalTo: pickerViewObj.actionView.topAnchor).isActive = true
            pickerViewObj.doneButton.bottomAnchor.constraint(equalTo: pickerViewObj.actionView.bottomAnchor).isActive = true
            pickerViewObj.doneButton.rightAnchor.constraint(equalTo: pickerViewObj.actionView.rightAnchor, constant: 10).isActive = true
            pickerViewObj.doneButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            
            
            
        }
    }
    
    @objc func doneButtonAction()
    {
        self.hidePickerView()
        ShowPickerView.pickerViewObj.delegation?.didTappedDoneButton(selectedValueForComponent1: ShowPickerView.pickerViewObj.dataSourceArrayForComponent1![self.selectedRow(inComponent: 0)], selectedValueForComponent2: ShowPickerView.pickerViewObj.dataSourceArrayForComponent2![self.selectedRow(inComponent: 1)], index1: self.selectedRow(inComponent: 0), index2: self.selectedRow(inComponent: 1))
    }
    @objc func cancelButtonAction()
    {
        self.hidePickerView()
    }
    func hidePickerView() {
        ShowPickerView.pickerViewObj.actionView.removeFromSuperview()
        ShowPickerView.pickerViewObj.removeFromSuperview()
        ShowPickerView.pickerViewObj.containerView.removeFromSuperview()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            if let count = ShowPickerView.pickerViewObj.dataSourceArrayForComponent1?.count
            {
                return count
            }
        }else if component == 1{
            if let count = ShowPickerView.pickerViewObj.dataSourceArrayForComponent2?.count
            {
                return count
            }
        }
        
        
        return 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            return ShowPickerView.pickerViewObj.dataSourceArrayForComponent1![row]
        }else{
            return ShowPickerView.pickerViewObj.dataSourceArrayForComponent2![row]
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if component == 0{
            let attributedString = NSAttributedString(string: ShowPickerView.pickerViewObj.dataSourceArrayForComponent1![row], attributes: [NSAttributedStringKey.foregroundColor : ShowPickerView.pickerViewObj.pickerViewFontColor,])
            return attributedString
        }else{
            let attributedString = NSAttributedString(string: ShowPickerView.pickerViewObj.dataSourceArrayForComponent2![row], attributes: [NSAttributedStringKey.foregroundColor : ShowPickerView.pickerViewObj.pickerViewFontColor])
            return attributedString
        }
      
    }
}
class DeviceType{
    class func isIpad()->Bool
    {
        return UIDevice.current.userInterfaceIdiom == .pad ? true : false
    }
}
class Reachability {
    
    class func isAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}

class ShowAlertView{
    class func show(titleMessage:String="Success",desciptionMessage:String="Successfully completed")
    {
        CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "general_ok").capitalized], titleMsg: titleMessage, desciption: desciptionMessage.capitalizingFirstLetter(), userInfo: nil)
    }
}






















