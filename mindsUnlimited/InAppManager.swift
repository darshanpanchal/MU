

import Foundation
import StoreKit

enum OperationType{
    case restore
    case buy
}
class InAppManager: NSObject,SKProductsRequestDelegate,SKPaymentTransactionObserver,SKRequestDelegate {
    static let shared = InAppManager()
    let monthly = "a_r_subscription"
    var timer:Timer?
    var operationType:OperationType?
    var referenceOfMeditationView:MeditationView?
    var hasDoneTransaction = true
    var products: [SKProduct] = []{
        didSet{
            
            if operationType == .restore{
              
                hasDoneTransaction = false
                SKPaymentQueue.default().restoreCompletedTransactions()
            }
            
            guard let price = products.first?.price,let currecy = products.first?.priceLocale.currencyCode else{
                return
            }
           let titleOfPurchaseButton = Vocabulary.getWordFromKey(key: "inapp.popup.whould_you_like_to").capitalizingFirstLetter()+" "+String(describing: price)+" "+currecy+"/"+Vocabulary.getWordFromKey(key: "inapp.popup.month")+", "+Vocabulary.getWordFromKey(key: "inapp.popup.access_description")
        
            labelSubTitle.text = titleOfPurchaseButton
            
        }
    }
    
  
    func addObjerverForPayment(){
        SKPaymentQueue.default().add(self)
    }
    func loadProducts(operation:OperationType?) {
        
       
        if !Reachability.isAvailable() {
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.no_connection"))
            return
        }
        
        operationType = operation
        timer?.invalidate()
        
        if operation == .restore{
            ShowHud.show(loadingMessage: Vocabulary.getWordFromKey(key: operationType == .restore ? "inapp.loading_hud.restoring" : "loading_hud_purchasing").capitalized)
            self.perform(#selector(hideHud), with: nil, afterDelay: 3.8)
        }else if operation != nil{
            self.showPurchaseDetails()
        }
        
        let productIdentifiers:Set = [monthly]
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    @objc func hideHud(){
        ShowHud.hide()
    }
    
    @objc func hideHudAfterInterval(){
        ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
        timer?.invalidate()
    }
    
    
    func checkSubscriptionAvailability() {
       
        guard let receiptURL = Bundle.main.appStoreReceiptURL else{
            return
        }
        do {
            
            timer?.invalidate()
            ShowHud.show(loadingMessage: Vocabulary.getWordFromKey(key: operationType == .restore ? "inapp.loading_hud.restoring" : "loading_hud_purchasing").capitalized)
            timer = Timer(timeInterval: 50, target: self, selector: #selector(self.hideHudAfterInterval), userInfo: nil, repeats: false)
            
            let receipt = try Data(contentsOf: receiptURL)
            let requestContents: [String: Any] = [
                "receipt-data": receipt.base64EncodedString(options: []),
                "password": "2b42a513c47747b88816165ecd946f77"
            ]
            let appleServer = receiptURL.lastPathComponent == "sandboxReceipt" ? "sandbox" : "buy"
            let stringURL = "https://\(appleServer).itunes.apple.com/verifyReceipt"
            var request = URLRequest(url: URL(string: stringURL)!)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.timeoutInterval = 60
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
            
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:requestContents, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                return
            }
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if error == nil,data != nil  {
                    do{
                        if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: AnyObject]{
                            
                            if let recArray = json["latest_receipt_info"] as? [[String:AnyObject]], let letstObject = recArray.last,let expires_date = letstObject["expires_date"] as? String{
                                
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
                                if let expirationDate = formatter.date(from: expires_date){
                                 
                                    UserDefaults.standard.set(expirationDate, forKey: "expireDateOfSubscription")
                                    RegisterAndLoginView.sendSubscriptionStatusToServer()
                                    GoogleAnalytics.setEvent(id: "subsciption_expiry_data", title: String(describing: expirationDate))
                                    
                                    DispatchQueue.main.async(execute: {
                                        if self.referenceOfMeditationView != nil{
                                            self.referenceOfMeditationView!.collectionViewForMenu.reloadData()
                                            self.referenceOfMeditationView = nil
                                        }
                                        if let opType = self.operationType,opType == .restore{
                                            
                                            let title = String.has_valid_in_app_purchase() ?  Vocabulary.getWordFromKey(key: "inapp.popup.valid_sub").uppercased() : Vocabulary.getWordFromKey(key: "inapp.popup.invalid_sub").uppercased()
                                            let descrption = String.has_valid_in_app_purchase() ?   Vocabulary.getWordFromKey(key: "inapp.popup.subscription_restored").capitalized :  Vocabulary.getWordFromKey(key: "inapp.popup.subscription_expired").capitalized
                                            CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "general_ok").uppercased()], titleMsg: title, desciption: descrption.capitalizingFirstLetter(), userInfo: nil)
                                        }
                                       ShowSideMenu.showSideMenuObj.listingCollectionView.reloadData()
                                    })
                                }
                            }
                        }
                    }catch{
                    }
                }
                self.timer?.invalidate()
                DispatchQueue.main.async(execute: {
                    ShowHud.hide()
                })
            })
            task.resume()
            
            
        } catch {
          
            let appReceiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
            appReceiptRefreshRequest.delegate = self
            appReceiptRefreshRequest.start()
      
        }
  }
    
   
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
           
            if !self.hasDoneTransaction {
                if transaction.transactionState == .restored || transaction.transactionState == .purchased{
                    SKPaymentQueue.default().finishTransaction(transaction)
                    self.checkSubscriptionAvailability()
                    self.hasDoneTransaction = true
                    
                    if transaction.transactionState == .purchased{
                        
                        GoogleAnalytics.setEvent(id: "subsciption_purchased", title: "Subscription Purchased Date \(Date())")
                       
                        let title = Vocabulary.getWordFromKey(key: "inapp.purchase_welcome_pop.title")
                        var descrption = Vocabulary.getWordFromKey(key: "inapp.purchase_welcome_pop.desiciption_when_not_login")
                        
                        if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let _ = userDetails["Id"]{
                            descrption = Vocabulary.getWordFromKey(key: "inapp.purchase_welcome_pop.desiciption_when_login")
                        }
                       
                        CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "general_ok").uppercased()], titleMsg: title, desciption: descrption.capitalizingFirstLetter(), userInfo: nil)
                    }
                    
                }else if transaction.transactionState == .failed{
                    GoogleAnalytics.setEvent(id: "subsciption_failed", title: "Subscription Failed")
                    self.timer?.invalidate()
                    ShowHud.hide()
                }
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse){
    
        guard response.products.count > 0 else {
            self.timer?.invalidate()
            ShowToast.show(toatMessage: "No products found")
            return}
        self.products = response.products
  
    }
   
    @objc func clickedToBuy(){
        GoogleAnalytics.setEvent(id: "sub_clicked_to_buy", title: "Buy Subsciption Button")
        self.closePurchaseDetails()
        ShowHud.show(loadingMessage: Vocabulary.getWordFromKey(key: operationType == .restore ? "inapp.loading_hud.restoring" : "loading_hud_purchasing").capitalized)
        self.perform(#selector(hideHud), with: nil, afterDelay: 3.8)
        hasDoneTransaction = false
        guard let product = self.products.filter({$0.productIdentifier == monthly}).first else {
            ShowToast.show(toatMessage: "Purchase failed, Try again")
            return
        }
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
 
    }
  
    
    
    
    
    //MARK: POPUP view
    lazy var titleForMed:VerticalAlignedLabel={
        let label =  self.getLabel(isTitle: true)
        return label
    }()
    lazy var subTitleForMed:VerticalAlignedLabel={
        let label =  self.getLabel(isTitle: false)
        return label
    }()
    lazy var titleForStat:VerticalAlignedLabel={
        let label =  self.getLabel(isTitle: true)
        return label
    }()
    lazy var subTitleForStat:VerticalAlignedLabel={
        let label =  self.getLabel(isTitle: false)
        return label
    }()
    
    lazy var titleForReminder:VerticalAlignedLabel={
        let label =  self.getLabel(isTitle: true)
        return label
    }()
    lazy var subTitleForReminder:VerticalAlignedLabel={
        let label =  self.getLabel(isTitle: false)
        return label
    }()
    
    let backGroundViewOfPopup:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 0.2, alpha: 0.5)
        return view
    }()
    
    

    let imageViewToShowPurchaseDetails:UIImageView={
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.image = #imageLiteral(resourceName: "background")
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    
    lazy var labelTitle:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 30 : UIScreen.main.bounds.height < 569 ? 20 : 24)
        label.textColor = UIColor.getYellowishColor()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        if String.getSelectedLanguage() == "2"{
            label.numberOfLines = 2
        }
        return label
    }()
    
    lazy var labelSubTitle:UILabel={
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : (UIScreen.main.bounds.height < 569 ? 13 : 14))
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.getThemeTextColor()
        return label
    }()
    
 
    
    lazy var notNowButton:UIButton={
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.closePurchaseDetails), for: .touchUpInside)
        btn.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        return btn
    }()
    
    var termCndtionsButton:UIButton={
        let btn = UIButton()
        btn.addTarget(InAppManager.self, action: #selector(InAppManager.showTermConditions), for: .touchUpInside)
        btn.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return btn
    }()
    
    
    let heightOfCell:CGFloat = DeviceType.isIpad() ? 130 : (UIScreen.main.bounds.height < 569 ? 70 : 90)
    func getCellForPopUp(celltype:Int)->UIView{
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let iv = self.getImageView(imageType: celltype)
        view.addSubview(iv)
        let padding:CGFloat = (UIScreen.main.bounds.height < 569 ? 10 : 30)
        view.addConstraintsWithFormat("H:|[v0(\(self.heightOfCell-padding))]", views: iv)
        view.addConstraintsWithFormat("V:[v0(\(self.heightOfCell-padding))]", views: iv)
        iv.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        if celltype == 0 || celltype == 1{
            let seperator:UIView={
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
            
            view.addSubview(seperator)
            view.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: seperator)
            view.addConstraintsWithFormat("V:[v0(1.5)]", views: seperator)
            seperator.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 2).isActive = true
        }
        
        
        
        func setLAyout(title:UILabel,subTitle:UILabel){
            
            view.addSubview(title)
            title.leftAnchor.constraint(equalTo: iv.rightAnchor, constant: 5).isActive = true
            title.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -2).isActive = true
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
            title.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            view.addSubview(subTitle)
            subTitle.leftAnchor.constraint(equalTo: iv.rightAnchor, constant: 5).isActive = true
            subTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -2).isActive = true
            subTitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
            subTitle.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        }
        
        if celltype == 0{
            setLAyout(title: titleForMed, subTitle: subTitleForMed)
         
        }else if celltype == 1{
            setLAyout(title: titleForReminder, subTitle: subTitleForReminder)
       
        }else{
            setLAyout(title: titleForStat, subTitle: subTitleForStat)
        }
        
        return view
    }
    
    func getLabel(isTitle:Bool)->VerticalAlignedLabel{
        let label = VerticalAlignedLabel()
       label.translatesAutoresizingMaskIntoConstraints = false
        if isTitle{
             label.font = UIFont.boldSystemFont(ofSize: DeviceType.isIpad() ? 25 : (UIScreen.main.bounds.height < 569 ? 15 : 18))
            label.numberOfLines = 1
        }else{
             label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : (UIScreen.main.bounds.height < 569 ? 13 : 14))
             label.numberOfLines = 0
             label.verticalAlignment = .top
        }
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.getThemeTextColor()
        
        return label
   
    }
    
    func getImageView(imageType:Int)->UIImageView{
        
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        if imageType == 0{
            iv.image = #imageLiteral(resourceName: "downloads_white")
        }else if imageType == 1{
            iv.tintColor = UIColor.white
            iv.image = #imageLiteral(resourceName: "calander")
        }else{
            iv.image = #imageLiteral(resourceName: "statistic6")
        }
        return iv
    }
    
    
    lazy var purchaseButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize:DeviceType.isIpad() ? 22 : (UIScreen.main.bounds.height < 569 ? 16 : 20), weight: UIFont.Weight.thin)
        button.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        button.layer.cornerRadius = 20
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(self.clickedToBuy), for: .touchUpInside)
        button.showShadow()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    let autoRenewLabel:UILabel={
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : (UIScreen.main.bounds.height < 569 ? 13 : 14))
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.getThemeTextColor()
        return label
    }()
    
    func showPurchaseDetails(){
        
        if products.count == 0{
            self.loadProducts(operation: nil)
            ShowToast.show(toatMessage: "No products found, Try again")
            return
        }
        
        if let app = UIApplication.shared.delegate as? AppDelegate , let window = app.window{
          
            
            window.addSubview(backGroundViewOfPopup)
            
            window.addConstraintsWithFormat("H:|[v0]|", views: backGroundViewOfPopup)
            window.addConstraintsWithFormat("V:|[v0]|", views: backGroundViewOfPopup)
            
            self.labelTitle.text = Vocabulary.getWordFromKey(key: "inapp.popup.title_full_app_access").uppercased()
            autoRenewLabel.text = Vocabulary.getWordFromKey(key: "inapp.popup.bottom_label_cancel_anytime")
            purchaseButton.setTitle(Vocabulary.getWordFromKey(key: "inapp.popup.button_subscription").capitalizingFirstLetter(), for: .normal)
            
            self.titleForStat.text = Vocabulary.getWordFromKey(key: "general.title.statistics").capitalizingFirstLetter()
            self.subTitleForStat.text = Vocabulary.getWordFromKey(key: "inapp.popup.statistic_description").capitalizingFirstLetter()
            
            self.titleForReminder.text = Vocabulary.getWordFromKey(key: "inapp.popup.reminders").capitalizingFirstLetter()
            self.subTitleForReminder.text = Vocabulary.getWordFromKey(key: "inapp.popup.reminder_description").capitalizingFirstLetter()
            
            self.titleForMed.text = Vocabulary.getWordFromKey(key: "inapp.popup.meditations").capitalizingFirstLetter().trim()
            self.subTitleForMed.text = Vocabulary.getWordFromKey(key: "inapp.popup.meditation_description").capitalizingFirstLetter()
            
            self.notNowButton.setTitle(Vocabulary.getWordFromKey(key: "inapp.popup.button_not_now"), for: .normal)
            termCndtionsButton.setTitle(Vocabulary.getWordFromKey(key: "inapp.popup.term_condition"), for: .normal)
            
           
            if !imageViewToShowPurchaseDetails.subviews.contains(notNowButton){
                
                
                backGroundViewOfPopup.addSubview(imageViewToShowPurchaseDetails)
                
                var hPadding = (UIScreen.main.bounds.height < 569 ? 10 : 20)
                var vPadding = (UIScreen.main.bounds.height < 569 ? 10 : 40)
                if UIScreen.main.bounds.height != 480 && UIScreen.main.bounds.height < 569{
                    vPadding = 50
                }
                
                if DeviceType.isIpad(){
                    
                    hPadding = 100
                    vPadding = 100
                }
                
                backGroundViewOfPopup.addConstraintsWithFormat("H:|-\(hPadding)-[v0]-\(hPadding)-|", views: imageViewToShowPurchaseDetails)
                backGroundViewOfPopup.addConstraintsWithFormat("V:|-\(vPadding)-[v0]-\(vPadding)-|", views: imageViewToShowPurchaseDetails)
                
                let heightOfNavigation:CGFloat = DeviceType.isIpad() ? 85 : (UIScreen.main.bounds.height < 569 ? 30 : 60)
                imageViewToShowPurchaseDetails.addSubview(self.labelTitle)
                imageViewToShowPurchaseDetails.addConstraintsWithFormat("H:|[v0]|", views: self.labelTitle)
                imageViewToShowPurchaseDetails.addConstraintsWithFormat("V:|-7-[v0(\(heightOfNavigation))]|", views: self.labelTitle)
                
                
                imageViewToShowPurchaseDetails.addSubview(labelSubTitle)
                imageViewToShowPurchaseDetails.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.labelSubTitle)
                labelSubTitle.topAnchor.constraint(equalTo: self.labelTitle.bottomAnchor, constant: 7).isActive = true
                
                let meditationCell = self.getCellForPopUp(celltype: 0)
                let reminderCell = self.getCellForPopUp(celltype: 1)
                let statisticCell = self.getCellForPopUp(celltype: 2)
                
                imageViewToShowPurchaseDetails.addSubview(meditationCell)
                imageViewToShowPurchaseDetails.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: meditationCell)
                meditationCell.topAnchor.constraint(equalTo: self.labelSubTitle.bottomAnchor, constant: 10).isActive = true
                imageViewToShowPurchaseDetails.addConstraintsWithFormat("V:[v0(\(self.heightOfCell))]", views: meditationCell)
                
                
                imageViewToShowPurchaseDetails.addSubview(reminderCell)
                imageViewToShowPurchaseDetails.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: reminderCell)
                imageViewToShowPurchaseDetails.addConstraintsWithFormat("V:[v0(\(self.heightOfCell))]", views: reminderCell)
                reminderCell.topAnchor.constraint(equalTo: meditationCell.bottomAnchor, constant: 10).isActive = true
                
                imageViewToShowPurchaseDetails.addSubview(statisticCell)
                imageViewToShowPurchaseDetails.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: statisticCell)
                imageViewToShowPurchaseDetails.addConstraintsWithFormat("V:[v0(\(self.heightOfCell))]", views: statisticCell)
                statisticCell.topAnchor.constraint(equalTo: reminderCell.bottomAnchor, constant: 10).isActive = true
                
                
                imageViewToShowPurchaseDetails.addSubview(purchaseButton)
                imageViewToShowPurchaseDetails.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: purchaseButton)
                imageViewToShowPurchaseDetails.addConstraintsWithFormat("V:[v0(\(self.heightOfCell/2))]", views: purchaseButton)
                self.purchaseButton.topAnchor.constraint(equalTo: statisticCell.bottomAnchor, constant: 20).isActive = true
                
                
                imageViewToShowPurchaseDetails.addSubview(autoRenewLabel)
                imageViewToShowPurchaseDetails.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: autoRenewLabel)
                autoRenewLabel.topAnchor.constraint(equalTo: self.purchaseButton.bottomAnchor, constant: 10).isActive = true
                
                
                
                
                imageViewToShowPurchaseDetails.addSubview(notNowButton)
                imageViewToShowPurchaseDetails.addSubview(termCndtionsButton)
            
              
                let padding:CGFloat = UIScreen.main.bounds.height < 569 ? 4 : 12
                
                notNowButton.centerXAnchor.constraint(equalTo: self.autoRenewLabel.centerXAnchor, constant: 0).isActive = true
                notNowButton.topAnchor.constraint(equalTo: autoRenewLabel.bottomAnchor, constant:padding).isActive = true
                self.notNowButton.heightAnchor.constraint(equalToConstant: 17).isActive = true
                termCndtionsButton.centerXAnchor.constraint(equalTo: self.autoRenewLabel.centerXAnchor, constant: 0).isActive = true
                termCndtionsButton.topAnchor.constraint(equalTo: notNowButton.bottomAnchor, constant:padding).isActive = true
                termCndtionsButton.heightAnchor.constraint(equalToConstant: 15).isActive = true
              
            }
        
        }
    }
    
    @objc func closePurchaseDetails(){
        GoogleAnalytics.setEvent(id: "closePurchaseDetails", title: "Close In-App Popup Dialouge")
        self.backGroundViewOfPopup.removeFromSuperview()
        
    }
    
    @objc static func showTermConditions(){
       
        GoogleAnalytics.setEvent(id: "show_terms_condtions", title: "Show Term&Condtions Button")
        InAppManager.shared.closePurchaseDetails()
        
        let linkToShowTerms = "https://www.sthlmapplab.com/terms-conditions"//"https://www.stockholmapplab.com/terms-of-use"
        
        UIApplication.shared.openURL(URL(string: linkToShowTerms)!)
   
    }
    
 
  
}







