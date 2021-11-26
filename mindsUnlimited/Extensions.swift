import UIKit

extension UIView
{
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    func getUUID()->String
    {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    
    func showNoDataFound(msg:String = "No Content Found"){
        
        self.removeNoDataLabel()
        
        let noDataLabel:UILabel={
            let label = UILabel(frame: self.bounds)
            label.font = UIFont.italicSystemFont(ofSize: DeviceType.isIpad() ? 16 : 14)
            label.textColor = UIColor.getThemeTextColor()
            label.tag = 112103
            label.numberOfLines = 0
            label.textAlignment = .center
            label.text = msg.capitalized
            return label
        }()
        self.addSubview(noDataLabel)
    }
   
    func removeNoDataLabel(){
        for view1 in self.subviews{
            if view1.tag == 112103{
                view1.removeFromSuperview()
            }
        }
    }
    
    func showShadow(){
        self.layer.shadowColor =  UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 3, height: 5)
        self.layer.shadowRadius = 0.7
        self.layer.masksToBounds = false
    }
    
}



extension UIColor {
    static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    static func getThemeTextColor()->UIColor{
        return UIColor.rgb(15, green: 10, blue: 78)
    }
    
    static func getYellowishColor()->UIColor{
        return UIColor.rgb(254, green: 193, blue: 0)
    }
    
    static func switchColor()->UIColor{
        return UIColor.getThemeTextColor()//UIColor.rgb(14, green: 195, blue: 249)
    }
}
extension String
{
    
    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first.uppercased() + other.lowercased()
    }
    
    func removeWhiteSpaces()->String
    {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }
    
    func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    
    static func getSelectedLanguage()->String{
        if let selection = UserDefaults.standard.value(forKey: "selectedLanguageCode") as? String{ // 1 eng , 2 swed
            return selection.removeWhiteSpaces().lowercased()
        }
        return "1"
    }
    
    static func has_full_access()->Bool{
        
        var isValid = false
        if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject],userDetails["groupCode"] != nil,let isValidGroup = userDetails["isValidGroup"] as? Bool,isValidGroup{
            isValid = true
        }else{
            isValid = String.has_valid_in_app_purchase()
        }
     
        
        
        if isValid{
            if UIApplication.shared.scheduledLocalNotifications?.count == 0{
                HomeViewController.setNotificationForDailyMsg()
            }
        }else{
            if UIApplication.shared.scheduledLocalNotifications?.count != 0{
                UIApplication.shared.cancelAllLocalNotifications()
            }
        }
        
        return isValid
    }
    
    static func has_valid_in_app_purchase()->Bool{
        if let lastSyncedDateAndTime = UserDefaults.standard.value(forKey: "expireDateOfSubscription") as? Date{
            let currentDateAndTime = Date()
            let diffTimeInterval = lastSyncedDateAndTime.timeIntervalSince(currentDateAndTime)
            let hours = (diffTimeInterval / 3600)
            return hours < 0 ? false : true
        }
        return false
    }
    
    
    static func get_device_token()->String{
        if let token = UserDefaults.standard.value(forKey: "deviceToken") as? String{
            return token
        }
        return "couldNotGetDeviceToken"
    }
    
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    
    
}
extension TimeInterval {
    var durationText:String {
        let totalSeconds = self
        let hours:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 86400) / 3600)
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
        
    }
}

extension Dictionary
{
    func updatedValue(_ value: Value, forKey key: Key) -> Dictionary<Key, Value> {
        var result = self
        result[key] = value
        return result
    }
    
    var nullsRemoved: [Key: Value] {
        let tup = filter { !($0.1 is NSNull) }
        return tup.reduce([Key: Value]()) { $0.updatedValue($1.value, forKey: $1.key) }
    }
    
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
}

extension NSMutableAttributedString {
    
    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSAttributedStringKey.link, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}







