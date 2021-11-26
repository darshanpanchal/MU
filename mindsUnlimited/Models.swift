//
//  SoundDetails.swift
//  mindsUnlimited
//
//  Created by IPS on 11/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import Foundation

class AudioDetails:NSObject{
    
    var nr:Int?{
        didSet{
            if let titleVal = title{
                
                let stringToSuffix = String(describing: nr!) + ". "
                if !titleVal.contains(stringToSuffix){
                     title = String(describing: nr!) + ". " + titleVal
                }
            }
        }
    }
    var languageId:Int?
    var title:String?
    var subTitle:String?
    var files:[AudioAttributes]?{
        didSet{
            if let totalFiles = files,totalFiles.count != 0{
                let firstObject = totalFiles.first!
                let durationOfAudio = firstObject.duration == nil ? "0.0 min" : firstObject.duration! + " min"
                var voiceType = "Man & \(Vocabulary.getWordFromKey(key: "general.woman").capitalizingFirstLetter())"
                
                if totalFiles.count == 1,let genderVal = firstObject.gender{
                    if genderVal == .woman{
                        voiceType = Vocabulary.getWordFromKey(key: "general.woman").capitalizingFirstLetter()
                    }else{
                        voiceType = "Man"
                    }
                }
                subTitle =  durationOfAudio + " - " + voiceType
            }
        }
    }
    var isFav = false
    var isPaid = false
}
enum Gender{
    
    case man
    case woman
}
class AudioAttributes:NSObject{
    var id:Int?
    var gender:Gender?
    var fileOriginalName:String?
    var duration:String?
    var fileURL:String?
    var localPath:String?
}
class DataSourceForCollectionView:NSObject{
    var favouriteAudio:[AudioDetails]?
    var downloadedAudio:[AudioDetails]?
    var downloadableAudio:[AudioDetails]?
}

class Language:NSObject{
    var title:String?
    var imageName:String?
}

class GroupFriend:NSObject{
    var userId:Int?
    var name:String?
    var email:String?
    var additionalInfo:String?
    var photoUrl:String?
    var status:Int?
}
struct Statistics {
    var points:Int
    var name:String
    var userId:Int
}

class NotiticationModel:NSObject{
    var id:String?{
        didSet{
            if let friendRequest = UserDefaults.standard.object(forKey: "friendRequest") as? [[String:AnyObject]]{
                for object in friendRequest{
                    if String(describing: object["not_id"]!) == id{
                        self.other = object
                        break
                    }
                }
            }
        }
    }
    var category:String?
    var created_date:String?
    var title:String?
    var note:String?
    var user_id:String?
    var target:String?
    var hasRead:String?
    var url:String?
    var other:[String:AnyObject]?
    var friendRequestId:String?
}

