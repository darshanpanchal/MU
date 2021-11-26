//
//  Vocabalary.swift
//  mindsUnlimited
//
//  Created by IPS on 03/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import Foundation
class Vocabulary:NSObject{
    static func getWordFromKey(key:String)->String{
        return getWordFromLocalPlist(key: key.removeWhiteSpaces())
    }
    
    
    private static func getWordFromLocalPlist(key:String)->String{
        
        
        let selectedLanguage = String.getSelectedLanguage() == "1" ? "EnglishVocabalary" : "SwedishVocabalary"
        var vocabDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: selectedLanguage, ofType: "plist") {
            vocabDictionary = NSDictionary(contentsOfFile: path)
        }
        
        if let vocabsDictnary1 = vocabDictionary,let value = vocabsDictnary1[key] as? String{
            return value
        }
        return key.replacingOccurrences(of: "_", with: " ")
        
    }
    
}
