//
//  CustomAlerView.swift
//  mindsUnlimited
//
//  Created by IPS on 15/03/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit

protocol customAlertDelegates:class{
    
    func didTappedCustomAletButton(selectedIndex:Int,title:String,userInfo:[String:AnyObject]?)
}


class CustomAlerView: UIView {

    static var userInfo:[String:AnyObject]?
    static var delegation:customAlertDelegates?
    
    static let fontOfDescriptionLalbe = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : 16, weight: UIFont.Weight(rawValue: -0.5))
    
    static let labelHeaderTitle:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor.getYellowishColor()
        label.text = "N/A"
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 20 : 18, weight: UIFont.Weight(rawValue: 0.7))
        label.backgroundColor = .clear
        return label
    }()
    static let labelDescrption:UITextView={
        let label = UITextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor.getThemeTextColor()
        label.text = ""
         //  label.numberOfLines = 0
         //   label.isUserInteractionEnabled = false
        // label.adjustsFontSizeToFitWidth = true
        label.font = fontOfDescriptionLalbe
        label.backgroundColor = .clear
        label.isEditable = false
        return label
    }()
  
    
    static let backgroundView:UIView={
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.init(white: 0, alpha: 0.4)
        return container
    }()
    
    
    static var alertViewContainer:UIView={
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.init(white: 1, alpha: 1)
        container.layer.masksToBounds = true
        container.layer.cornerRadius = 16
        return container
    }()
    
    static let backgroudImageView:UIImageView={
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = #imageLiteral(resourceName: "background")
        iv.contentMode = .scaleToFill
        return iv
    }()
    class func setUpPopup(buttonsName: [String], titleMsg: String,desciption:String="",userInfo:[String:AnyObject]?){
       
        
        DispatchQueue.main.async { 
            if let keyWindow = UIApplication.shared.keyWindow{
                
                CustomAlerView.userInfo = userInfo
                
                let widthOfPopupView = DeviceType.isIpad() ? 320 : 270
                var heightOfPopView = DeviceType.isIpad() ? 150 : 120
                
                let sizeOfHeaderView:CGFloat = CGFloat(widthOfPopupView/5)
                
                
                let constraintRect = CGSize(width:keyWindow.frame.width, height: keyWindow.frame.height)
                let boundingBox = desciption.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: fontOfDescriptionLalbe], context: nil)
                heightOfPopView = (heightOfPopView+Int(boundingBox.height+30))
                
                if heightOfPopView > Int(UIScreen.main.bounds.height-20){
                    heightOfPopView = Int(UIScreen.main.bounds.height-20)
                    labelDescrption.isUserInteractionEnabled = true
                }else{
                    labelDescrption.isUserInteractionEnabled = false
                }
                
                
                let bottomPadding:CGFloat = DeviceType.isIpad() ? 15 : 10
                let heightOfButton:CGFloat = DeviceType.isIpad() ? 40 : 30
                let gapBwTwoButtons:CGFloat = DeviceType.isIpad() ? 10 : 7
                
                labelHeaderTitle.text = titleMsg
                labelDescrption.text = desciption
                keyWindow.addSubview(backgroundView)
                keyWindow.addConstraintsWithFormat("H:|[v0]|", views: backgroundView)
                keyWindow.addConstraintsWithFormat("V:|[v0]|", views: backgroundView)
                
                backgroundView.addSubview(alertViewContainer)
                
                let extraHeight = 20
                
                backgroundView.addConstraintsWithFormat("H:[v0(\(widthOfPopupView+extraHeight))]", views: alertViewContainer)
                backgroundView.addConstraintsWithFormat("V:[v0(\(heightOfPopView))]", views: alertViewContainer)
                
                alertViewContainer.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
                alertViewContainer.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
                
                alertViewContainer.addSubview(backgroudImageView)
                alertViewContainer.addConstraintsWithFormat("H:|[v0]|", views: backgroudImageView)
                alertViewContainer.addConstraintsWithFormat("V:|[v0]|", views: backgroudImageView)
                
                backgroudImageView.addSubview(labelDescrption)
                backgroudImageView.addSubview(labelHeaderTitle)
                
                backgroudImageView.addConstraintsWithFormat("H:|-5-[v0]-5-|", views: labelHeaderTitle)
                backgroudImageView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: labelDescrption)
                
                backgroudImageView.addConstraintsWithFormat("V:|[v0(\(sizeOfHeaderView))][v1]-\(bottomPadding+heightOfButton+12)-|", views: labelHeaderTitle,labelDescrption)
                
                var buttonArray = [UIButton]()
                var viewDict = [String:AnyObject]()
                for (index,title) in buttonsName.enumerated(){
                    
                    let btn = UIButton()
                    btn.tag = index + 100
                    btn.setTitle(title.uppercased(), for: .normal)
                    btn.backgroundColor = .white
                    btn.showShadow()
                    btn.titleLabel?.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 16 : 14)
                    btn.titleLabel?.numberOfLines = 2
                    btn.titleLabel?.textAlignment = .center
                    btn.layer.cornerRadius = 16
                    btn.titleLabel?.adjustsFontSizeToFitWidth = true
                    btn.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
                    btn.addTarget(CustomAlerView.self, action: #selector(CustomAlerView.buttonPressed), for: .touchUpInside)
                    buttonArray.append(btn)
                }
                
                var horizontalString = "H:|"
                for (index,button) in buttonArray.enumerated(){
                    
                    backgroudImageView.addSubview(button)
                    backgroudImageView.addConstraintsWithFormat("V:[v0(\(heightOfButton))]-\(bottomPadding)-|", views:button)
                    if index == 0{
                        let size = "v"+String(buttonArray.count == 1 ? 0 : 1)
                        horizontalString += "-\(gapBwTwoButtons)-[v\(index)(\(size))]-\(gapBwTwoButtons)-"
                    }else{
                        let size = "v"+String(buttonArray.count-1 == index ? 0 : index+1)
                        horizontalString += "[v\(index)(\(size))]-\(gapBwTwoButtons)-"
                    }
                    viewDict["v\(index)"] = button
                    
                }
                horizontalString += "|"
                
                backgroudImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: horizontalString, options: NSLayoutFormatOptions(), metrics: nil, views: viewDict))
                
                
                
            }
            
        }
        
        
   
    
    }
    
    
    
    @objc class func buttonPressed(sender:UIButton){
     
        GoogleAnalytics.setEvent(id: "custom_alert_view", title: "Alert Button")
        
        for obj in alertViewContainer.subviews{
            obj.removeFromSuperview()
        }
        for obj in backgroudImageView.subviews{
            obj.removeFromSuperview()
        }
        alertViewContainer.removeFromSuperview()
        backgroundView.removeFromSuperview()
        delegation?.didTappedCustomAletButton(selectedIndex: sender.tag - 100,title: sender.title(for: .normal)!.lowercased().removeWhiteSpaces(), userInfo: userInfo)
        delegation = nil

    }
   
 
}



