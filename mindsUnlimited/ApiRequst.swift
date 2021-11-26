//
//  ApiRequst.swift
//  mindsUnlimited
//
//  Created by IPS on 03/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import Foundation



class ApiRequst:NSObject{
    static let serverURL = "http://mindsunlimited.stockholmapplab.com/api/"
    
    //http://mindsunlimited.stockholmapplab.com/api/   http://1.22.229.11/MindsUnlimited/Api/
    
    
    enum RequestType {
        case POST
        case GET
        case PUT
        case DELETE
        case OPTIONS
    }
    static func doRequest(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,showHUD:Bool = true,completionHandler:@escaping ([String:AnyObject])->()){
        
       
        if !Reachability.isAvailable() {
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.no_connection"))
            return
        }
        
        func unknownError(){
            if showHUD{
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
            }
        }
        
        if showHUD{
              ShowHud.show()
        }
        
        let urlString = serverURL + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
       
        if let userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject],let accessToken = userDetails["AccessToken"] as? String, let _ = userDetails["Id"]{
             request.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
             request.setValue(String.getSelectedLanguage(), forHTTPHeaderField: "LanguageId")
        }
        
        
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                unknownError()
                return
            }
        }
        
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            
            DispatchQueue.main.async(execute: {
                ShowHud.hide()
            })
            if error == nil,data != nil
            {
                //print(String(data: data!, encoding: .utf8)!)
                if let httpStatus = response as? HTTPURLResponse  { // checks http errors
                    if httpStatus.statusCode == 200{
                        do{
                            if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: AnyObject]{
                                completionHandler(json)
                                return
                            }
                        }
                        catch{
                            completionHandler(["status":"200" as AnyObject])
                            return
                        }
                    }else
                    {
                        do{
                            if let errArray = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [[String: AnyObject]]{
                                if errArray.count != 0{
                                    let firstObj = errArray[0]
                                    if let firstMsg = firstObj["ErrorMessage"] as? String ,  firstMsg.count != 0{
                                        if showHUD{
                                            DispatchQueue.main.async(execute: { 
                                                ShowToast.show(toatMessage:firstMsg)
                                            })
                                            
                                            
                                        }
                                       
                                        return
                                    }
                                }
                            }
                        }
                        catch{ }
                    }
                    
                }
            }
            DispatchQueue.main.async(execute: { 
                unknownError()
            })
            
          
        })
        task.resume()
        
    }
}

