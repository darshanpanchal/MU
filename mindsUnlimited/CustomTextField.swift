//
//  CustomTextField.swift
//  mindsUnlimited
//
//  Created by IPS on 14/03/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

  
    
    
    let languageMenuSeperator1:UIView={
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
    
    let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 1))
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        self.leftViewMode = .always
        self.leftView = leftPadding
        
        self.addSubview(languageMenuSeperator1)
        self.addConstraintsWithFormat("H:|-4-[v0]-4-|", views: languageMenuSeperator1)
        self.addConstraintsWithFormat("V:[v0(1.5)]-2-|", views: languageMenuSeperator1)
    }
    
    override var placeholder: String?{
        didSet{
           self.attributedPlaceholder =  NSAttributedString(string: placeholder!, attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray])
        }
    }
    
}
