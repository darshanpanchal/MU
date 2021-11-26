import Foundation
import UIKit

let shared = DBManger()

class DBManger: NSObject {
    
    var db: FMDatabase? = nil
    
    class func copyFile(fileName:String)->Bool {
        var error:NSError?
        let dbPath:String = getPath(fileName: fileName as String)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath)
        {
            let documentsURL = Bundle.main.resourceURL
            let fromPath = documentsURL?.appendingPathComponent(fileName)
            do
            {
                try fileManager.copyItem(atPath: fromPath!.path, toPath: dbPath)
            }
            catch let error1 as NSError
            {
                error = error1
            }
        }
        return error != nil ? false : true
       
    }
    
    class  func getPath(fileName:String) -> String
    {
        let docUrl=FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docUrl.appendingPathComponent(fileName)
        return fileURL.path
    }
    
    
    
    
    class func dbGenericQuery(queryString:String)->[[String:AnyObject]]
    {
        
        if(shared.db == nil)
        {
            shared.db = FMDatabase(path:DBManger.getPath(fileName: "database.sqlite") as String)
        }
        shared.db?.open()
        
        var result = [[String:AnyObject]]()
        
        if shared.db!.open()
        {
            
            if let resultSet = shared.db!.executeQuery(queryString, withArgumentsIn: nil) {
                while resultSet.next()
                {
                    if let resultFromDatabase = resultSet.resultDictionary() as? [String:AnyObject]{
                        result.append(resultFromDatabase)
                    }else{
                        print("### could not typecast result ###")
                    }
                }
            }else{
               // CustomAlerView.setUpPopup(buttonsName: ["OK"], titleMsg: "Database Failur", desciption: "Some issue occured with database, Please contact admin", userInfo: nil)
            }
           
        }
        shared.db!.close()
        return result
    }
    
    class func initilizeDatabase(){
        
        if DBManger.copyFile(fileName: "database.sqlite"){
            
            //to create table
            let query1 = "CREATE TABLE IF NOT EXISTS downloadedAudios (serialNumber INTEGER PRIMARY KEY AUTOINCREMENT, nr VARCHAR, languageId VARCHAR, title VARCHAR, isFave VARCHAR, isPaid VARCHAR)"
            let query2 = "CREATE TABLE IF NOT EXISTS audioAttributes (serialNumber INTEGER PRIMARY KEY AUTOINCREMENT, nr VARCHAR, id VARCHAR, gender VARCHAR, languageId VARCHAR, fileOriginalName VARCHAR,duration VARCHAR, fileURL VARCHAR, localPath VARCHAR)"
            let query3 = "CREATE TABLE IF NOT EXISTS purchasesAudioIds (serialNumber INTEGER PRIMARY KEY AUTOINCREMENT,id VARCHAR,desriptions VARCHAR)"
            let query4 = "CREATE TABLE IF NOT EXISTS notifications (serialNumber INTEGER PRIMARY KEY AUTOINCREMENT,id VARCHAR,category VARCHAR,created_date DATETIME,title VARCHAR,note VARCHAR,user_id VARCHAR,target VARCHAR,hasRead VARCHAR,other VARCHAR,url VARCHAR,friend_request_id VARCHAR)"
            _ = DBManger.dbGenericQuery(queryString: query1)
            _ = DBManger.dbGenericQuery(queryString: query2)
            _ = DBManger.dbGenericQuery(queryString: query3)
            _ = DBManger.dbGenericQuery(queryString: query4)
         
            var isNotificationColumnExist = false
            var isBadgeEnabledColumnExist = false
            let tableInfo = DBManger.dbGenericQuery(queryString: "PRAGMA table_info(notifications)")
            for column in tableInfo{
                if let columnName = column["name"] as? String {
                    if columnName == "friend_request_id"{
                        isNotificationColumnExist = true
                    }
                    if columnName == "is_badge_enabled"{
                        isBadgeEnabledColumnExist = true
                    }
                }
            }
          
            if !isNotificationColumnExist{
                _ = DBManger.dbGenericQuery(queryString:  "ALTER TABLE notifications ADD COLUMN friend_request_id VARCHAR")
            }
            
            if !isBadgeEnabledColumnExist{
                _ = DBManger.dbGenericQuery(queryString:  "ALTER TABLE notifications ADD COLUMN is_badge_enabled VARCHAR")
            }
       
        }else{
            ShowAlertView.show(titleMessage: "Error", desciptionMessage: "Could not load databse, Cantact admin")
        }
    }

}
