//
//  GoogleAnalytics.swift
//  mindsUnlimited
//
//  Created by IPS on 30/05/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class GoogleAnalytics:NSObject{
    static func setEvent(id:String,title:String,contType:String = "cont"){
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            
            AnalyticsParameterItemID: "id-\(id)" as NSObject,
            AnalyticsParameterItemName: title as NSObject,
            AnalyticsParameterContentType: "contType" as NSObject
            ])
        
        FBSDKAppEvents.logEvent(title)
       
    }
    
    
    static func setScreen(name:String,className:String){
         Analytics.setScreenName(name, screenClass: className)
         FBSDKAppEvents.logEvent(name)
    }
    
}


