//
//  MeditationView.swift
//  mindsUnlimited
//
//  Created by IPS on 08/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit
import  CoreData


enum DidTapCellOperaiotn {
    case play
    case removeFromFav
    case removeFromDownloaded
    case didTapToBuy
    case didTapToDownload
}
enum CellType {
    case favourite
    case downloaded
    case downloadable
    case store
}

let heightOfCellTodisplaySoundDetails:CGFloat = DeviceType.isIpad() ? 90 : 65

var referenceOfMeditationView:MeditationView?

var alreadyDownloadedAudioIds = [Int]()


class MeditationView: GeneralViewController,MenuItemDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,customAlertDelegates {
    
    //MARK: Class properties
   
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    
    static let languageMenuSeperator1:UIView={
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 0.7
        view.layer.masksToBounds = false
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    static let languageMenuSeperator2:UIView={
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 0.7
        view.layer.masksToBounds = false
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var dataTask: URLSessionDataTask?
    
    
    let bottomMenuContainer = MenuItemsCollection()
    let languageSelectionMenu = MenuItemsCollection()
   
    var dataSourceForCollectionView:DataSourceForCollectionView?{
        didSet{
           collectionViewForMenu.reloadData()
            
        }
    }
    var josnReponseOfMeditationList:[String:AnyObject]?
    
    let reUsableId = "cellId"
    
    lazy var collectionViewForMenu:UICollectionView={
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        cv.backgroundColor = .clear
        cv.register(CellForMeditation.self, forCellWithReuseIdentifier:self.reUsableId)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        return cv
    }()
    
    //MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ShowSideMenu.showSideMenuObj.selectedCell = -1
        
        alreadyDownloadedAudioIds.removeAll()
        let resultOfDownloadedId = DBManger.dbGenericQuery(queryString: "select id from audioAttributes")
        
        for idObject in resultOfDownloadedId{
            if let id = idObject["id"] as? String, let intValue = Int(id){
                alreadyDownloadedAudioIds.append(intValue)
            }
        }
        
        self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "meditationview.my_meditation").uppercased()
        
        self.setUpView()
        self.getSoundListFromServer()
        
        referenceOfMeditationView = self
        
    }
    
    //MARK: CollectionView Delegates
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reUsableId, for: indexPath) as! CellForMeditation
        if dataSourceForCollectionView != nil{
            cell.dataSource = self.dataSourceForCollectionView!
            cell.cellIndex = indexPath.row
        }
       
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: self.collectionViewForMenu.frame.width, height:self.collectionViewForMenu.frame.height)
        
    }
    
    //MARK: Other methods
    func setUpView(){
     
        
        let bottomView:UIView={
            let view = UIView()
            view.backgroundColor = UIColor.init(white: 0, alpha: 0)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let heightOfBottomView:CGFloat = DeviceType.isIpad() ? 200 : UIScreen.main.bounds.height < 481 ? 140 : 150 // container
        let heightOfBottomMenu:CGFloat = DeviceType.isIpad() ? 110 : UIScreen.main.bounds.height < 481 ? 75 : 90
        
        let heightOfLanguageSelection:CGFloat = DeviceType.isIpad() ? 60 : 40
        
        self.backgroudImageView.addSubview(bottomView)
        self.backgroudImageView.addSubview(collectionViewForMenu)
        
        bottomView.addSubview(bottomMenuContainer)
        
        self.backgroudImageView.addConstraintsWithFormat("V:[v0(\(heightOfBottomView))]|", views: bottomView)
        self.backgroudImageView.addConstraintsWithFormat("H:|[v0]|", views: bottomView)
        
        self.backgroudImageView.addConstraintsWithFormat("H:|[v0]|", views: collectionViewForMenu)
        self.collectionViewForMenu.topAnchor.constraint(equalTo: self.customNavigationImageView.bottomAnchor, constant: 0).isActive = true
        self.collectionViewForMenu.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant:-2).isActive = true
        
        bottomMenuContainer.typeOfMenu = .myMeditation
        bottomMenuContainer.delegate = self
        bottomView.addConstraintsWithFormat("H:|-5-[v0]-5-|", views: bottomMenuContainer)
        bottomView.addConstraintsWithFormat("V:[v0(\(heightOfBottomMenu))]-2-|", views: bottomMenuContainer)
        
        let myMeditation = DataSourceForMenuCollection()
        myMeditation.uniqueId = "myMeditation"
        myMeditation.imageName = "my_med_white"
        myMeditation.titleForCell = Vocabulary.getWordFromKey(key: "meditationview.my_meditation").capitalizingFirstLetter()
        
        let download = DataSourceForMenuCollection()
        download.imageName = "downloads_white"
        download.uniqueId = "download"
        download.titleForCell = Vocabulary.getWordFromKey(key: "meditationview.label.downloads").capitalizingFirstLetter()

        bottomMenuContainer.menuDataSource = [myMeditation,download]
        
        bottomView.addSubview(self.languageSelectionMenu)
        languageSelectionMenu.typeOfMenu = .language
        languageSelectionMenu.delegate = self
        bottomView.addConstraintsWithFormat("H:|-30-[v0]-30-|", views: languageSelectionMenu)
        bottomView.addConstraintsWithFormat("V:|-15-[v0(\(heightOfLanguageSelection))]", views: languageSelectionMenu)
        
        let english = DataSourceForMenuCollection()
        english.uniqueId = "english"
        english.titleForCell = Vocabulary.getWordFromKey(key: "english").uppercased()
        
        let svenska = DataSourceForMenuCollection()
        svenska.uniqueId = "svenska"
        svenska.titleForCell = Vocabulary.getWordFromKey(key: "svenska").uppercased()
       
        languageSelectionMenu.menuDataSource = [english,svenska]
        
        
        MeditationView.setUpSeperatorOnLanguageMenu(languageSelectionMenu: languageSelectionMenu)
  
        MeditationView.languageMenuSeperator1.isHidden = true
        MeditationView.languageMenuSeperator2.isHidden = false
       
    }
    
    static func setUpSeperatorOnLanguageMenu(languageSelectionMenu:UIView){
        
        languageSelectionMenu.addSubview(languageMenuSeperator1)
        languageSelectionMenu.addConstraintsWithFormat("H:|[v0]|", views: languageMenuSeperator1)
        languageSelectionMenu.addConstraintsWithFormat("V:|[v0(2)]", views: languageMenuSeperator1)
        
        languageSelectionMenu.addSubview(languageMenuSeperator2)
        languageSelectionMenu.addConstraintsWithFormat("H:|[v0]|", views: languageMenuSeperator2)
        languageSelectionMenu.addConstraintsWithFormat("V:[v0(2)]|", views: languageMenuSeperator2)
    }
   
    
    func getSoundListFromServer(){
       let selectedLanguageCode = String.getSelectedLanguage().removeWhiteSpaces() == "1" ? 1 : 2
       languageSelectionMenu.collectionViewForMenu.selectItem(at: IndexPath(row: selectedLanguageCode-1, section: 0), animated: true, scrollPosition: .left)
        
        
        if Reachability.isAvailable(){
            var param = ["Pricing":"","LanguageId":"","Gender":""]
            var queryString =  "meditations/list"
            if let userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
            
                queryString = "users/\(userId)/meditations/list"
                param = ["":""]
            }
            ApiRequst.doRequest(requestType: .POST, queryString: queryString, parameter: param as [String : AnyObject]) { (json) in
                
                DispatchQueue.main.async{
                    
                    self.josnReponseOfMeditationList = json
                    
                    
                    self.willLoadDataOnCollectionView(languageId: selectedLanguageCode)
                    
                }
            }
            
        }else{
            
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.no_connection"))
            self.willLoadDataOnCollectionView(languageId: selectedLanguageCode)
          
        }
    }
    
    func willLoadDataOnCollectionView(languageId:Int){
       
        let tempDataSourceForCollectionView = DataSourceForCollectionView()
        let favAndDownloaded = getFavAndDownloadedFromDatabase(languageIdToSearch: languageId)
        
        tempDataSourceForCollectionView.favouriteAudio = favAndDownloaded.favourite
        tempDataSourceForCollectionView.downloadedAudio = favAndDownloaded.downloaded
        
        
        var paidAudios = [AudioDetails]()
        
        var freeAudios = [AudioDetails]()
        
        if let jsonResponse = josnReponseOfMeditationList{
            
            if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject],userDetails["groupCode"] != nil{
                
                if let isValidGroup = jsonResponse["InGroup"] as? Bool{
                    userDetails["isValidGroup"] = isValidGroup as AnyObject?
                    UserDefaults.standard.set(userDetails.nullsRemoved, forKey: "userDetails")
                }
            }
            
            if let languagesArray = jsonResponse["Languages"] as? [[String:AnyObject]]{
                for selectedLanuage in languagesArray{
                    if let currentLangId = selectedLanuage["LanguageId"] as? Int,currentLangId == languageId{
                        
                        if let meditationsArray = selectedLanuage["Meditations"] as? [[String:AnyObject]]{
                            for meditation in meditationsArray{
                                
                                if let itemsArray = meditation["Items"] as? [[String:AnyObject]]{
                                    
                                    for  meditationAudioDetails in itemsArray{
                                        
                                        if let nrValue = meditationAudioDetails["Nr"] as? Int{
                                            
                                            let audioDetails = AudioDetails()
                                            
                                            if let val = meditationAudioDetails["Name"] as? String{
                                                audioDetails.title = val
                                            }
                                            audioDetails.nr = nrValue
                                            audioDetails.languageId = languageId
                                            
                                            
                                            var isItemPaid = true
                                            
                                            if let isPaid = meditation["Pricing"] as? String{
                                                if isPaid.lowercased().replacingOccurrences(of: " ", with: "").contains("free"){
                                                    isItemPaid = false
                                                }
                                            }
                                            
                                            audioDetails.isPaid = isItemPaid
                                            
                                            var audioAttributesArr = [AudioAttributes]()
                                            
                                            if let files = meditationAudioDetails["Files"] as? [[String:AnyObject]]{
                                                
                                                for attObject in files{
                                                    
                                                    let att = AudioAttributes()
                                                    if let val = attObject["Id"] as? Int{
                                                        att.id = val
                                                        
                                                    }
                                                    if let val = attObject["Gender"] as? String{
                                                        
                                                        att.gender = val.replacingOccurrences(of: " ", with: "").lowercased().contains("woman") ? .woman : .man
                                                    }
                                                    if let val = attObject["FileOriginalName"] as? String{
                                                        
                                                        att.fileOriginalName = val
                                                    }
                                                    if let val = attObject["Duration"] as? String{
                                                        
                                                        att.duration = val
                                                    }
                                                    if let val = attObject["FileUrl"] as? String{
                                                        
                                                        att.fileURL = val
                                                    }
                                                    audioAttributesArr.append(att)
                                                }
                                            }
                                            var downloadableItems = [AudioAttributes]()
                                            
                                            for attributeOfAudio in audioAttributesArr{
                                                
                                                if let attId = attributeOfAudio.id{
                                                 
                                                    if !alreadyDownloadedAudioIds.contains(attId){
                                                       
                                                        downloadableItems.append(attributeOfAudio)
                                                   
                                                    }
                                                }
                                            }
                                            if downloadableItems.count != 0{
                                                audioDetails.files = downloadableItems
                                                if isItemPaid{
                                                    paidAudios.append(audioDetails)
                                                }else{
                                                    freeAudios.append(audioDetails)
                                                }
                                                
                                            }
                                      
                                        }
                                        
                                    }
                                }
                            }
                        }
                        
                    }
                    
                }
            }
        }
        
        freeAudios.append(contentsOf: paidAudios)
        tempDataSourceForCollectionView.downloadableAudio = freeAudios
        dataSourceForCollectionView = tempDataSourceForCollectionView
  
    }
    
    func getFavAndDownloadedFromDatabase(languageIdToSearch:Int)->(favourite:[AudioDetails],downloaded:[AudioDetails]){
        
        var downloadedAudio = [AudioDetails]()
        var favouriteAudio = [AudioDetails]()
        
        let downloadedAndFavAudioResultFromSqlite = DBManger.dbGenericQuery(queryString: "SELECT * FROM downloadedAudios where languageId = '\(languageIdToSearch)'")
        
        for object in downloadedAndFavAudioResultFromSqlite{
          
            let audioDetails = AudioDetails()
            
            if let val = object["title"] as? String{
                audioDetails.title = val
            }
            
            if let nrString = object["nr"] as? String,let langIdString = object["languageId"] as? String{
                
                if let intVal = Int(nrString){
                    audioDetails.nr = intVal
                }
                if let intVal = Int(langIdString){
                    audioDetails.languageId = intVal
                }
                
                if let val = object["isPaid"] as? String, let boolVal = Bool(val){
                    audioDetails.isPaid = boolVal
                }else{
                     audioDetails.isPaid = true
                }
                
                let audioAttributesResultFromSqlite = DBManger.dbGenericQuery(queryString: "SELECT * FROM audioAttributes where nr = '\(nrString)' AND languageId = '\(langIdString)'")
                var audioAttributes = [AudioAttributes]()
                for attObject in audioAttributesResultFromSqlite{
                    let att = AudioAttributes()
                    if let val = attObject["id"] as? String,let intVal = Int(val){
                        
                        att.id = intVal
                    }
                    if let val = attObject["gender"] as? String{
                        
                        att.gender = val.replacingOccurrences(of: " ", with: "").lowercased().contains("woman") ? .woman : .man
                    }
                    if let val = attObject["fileOriginalName"] as? String{
                        
                        att.fileOriginalName = val
                    }
                    if let val = attObject["duration"] as? String{
                        
                        att.duration = val
                    }
                    if let val = attObject["fileURL"] as? String{
                        
                        att.fileURL = val
                    }
                    if let val = attObject["localPath"] as? String{
                        
                        att.localPath = val
                    }
                    audioAttributes.append(att)
                    
                }
                audioDetails.files = audioAttributes
                
            }else{
                continue
            }
            
            if let val = object["isFave"] as? String, let boolVal = Bool(val),boolVal{
                audioDetails.isFav = boolVal
                favouriteAudio.append(audioDetails)
            }else{
                downloadedAudio.append(audioDetails)
            }
        
        }
       
        return (favouriteAudio,downloadedAudio)
    }
    
    override func backButtonActionHandeler(){
      
        self.popToHomeView()
    }
    
    //MARK: Bottom menu selection
    func didSelectItemAtIndexPath(selectedCellInfo: DataSourceForMenuCollection) {
        if selectedCellInfo.uniqueId == "myMeditation"{
            GoogleAnalytics.setEvent(id: "my_meditation", title: "My Meditation")
            MeditationView.languageMenuSeperator1.isHidden = true
             self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "meditationview.my_meditation").uppercased()
             self.collectionViewForMenu.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .left)
       }else if selectedCellInfo.uniqueId == "download"{
           
             GoogleAnalytics.setEvent(id: "downloads", title: "downloads")
            if !Reachability.isAvailable() {
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.no_connection"))
            }
            
            MeditationView.languageMenuSeperator1.isHidden = true
            self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "meditationview.label.downloads").uppercased()
            self.collectionViewForMenu.selectItem(at: IndexPath(item: 1, section: 0), animated: true, scrollPosition: .left)
        }else if selectedCellInfo.uniqueId == "english"{
            GoogleAnalytics.setEvent(id: "language", title: "English Selected")
            self.willLoadDataOnCollectionView(languageId: 1)
        }else if selectedCellInfo.uniqueId == "svenska"{
            GoogleAnalytics.setEvent(id: "language", title: "Svenska Selected")
            self.willLoadDataOnCollectionView(languageId: 2)
        }
    }
    
    func didTapOnSoundCell(soundDetails:AudioDetails,selectedFile:AudioAttributes,operationType:DidTapCellOperaiotn){
        
        if let selectedIndexpath = self.languageSelectionMenu.collectionViewForMenu.indexPathsForSelectedItems?.first,let selectedId = selectedFile.id{
            
            if operationType == .removeFromDownloaded || operationType == .removeFromFav{
                
                GoogleAnalytics.setEvent(id: "remove_meditation", title: "Remove Or Remove-Favourite Meditation Button")
                
               CustomAlerView.delegation = self
                CustomAlerView.setUpPopup(buttonsName: [Vocabulary.getWordFromKey(key: "general_no").uppercased(), Vocabulary.getWordFromKey(key: "general_yes").uppercased()], titleMsg: Vocabulary.getWordFromKey(key: "meditationview.remove_item").uppercased(), desciption: Vocabulary.getWordFromKey(key: "medtationview.popup.removeitem.are_you_sure").capitalizingFirstLetter(), userInfo: ["soundDetails":soundDetails,"selectedFile":selectedFile,"operationType":operationType as AnyObject])
                
            }else if operationType == .didTapToBuy{
              
                self.downloadAudioFromServer(soundDetails: soundDetails, selectedFile: selectedFile, completionHandler: { (Bool) in
                    var orgName = ""
                    if let title = selectedFile.fileOriginalName{
                        orgName = title
                    }
                    _ = DBManger.dbGenericQuery(queryString: "INSERT INTO purchasesAudioIds(id,desriptions) VALUES ('\(selectedId)','\(orgName)')")
                    self.willLoadDataOnCollectionView(languageId: selectedIndexpath.item == 0 ? 1 : 2)
                })
                
            }else if operationType == .didTapToDownload{
               GoogleAnalytics.setEvent(id: "download_meditation", title: "Download Meditation Button")
                self.downloadAudioFromServer(soundDetails: soundDetails, selectedFile: selectedFile, completionHandler: { (Bool) in
                    
                })
          
            }else if operationType == .play{
            
                
                
                let playerView = AudioPlayerView()
                playerView.soundDetails = soundDetails
                playerView.selectedFile = selectedFile
                playerView.referenceOfMeditationView = self
                self.navigationController?.pushViewController(playerView, animated: true)
             
            }
            
        }
        
    }
    

    func didTappedCustomAletButton(selectedIndex:Int,title: String, userInfo: [String : AnyObject]?) {
        if let info = userInfo,selectedIndex == 1{
            if let soundDetails = info["soundDetails"] as? AudioDetails, let selectedFile = info["selectedFile"] as? AudioAttributes,let operationType = info["operationType"] as? DidTapCellOperaiotn,let selectedIndexpath = self.languageSelectionMenu.collectionViewForMenu.indexPathsForSelectedItems?.first,let selectedId = selectedFile.id  {
                
                if let nrNumber = soundDetails.nr{
                    var languageId = 1
                    if let val = soundDetails.languageId{
                        languageId = val
                    }
                    
                    if operationType == .removeFromDownloaded{
                        
                        _ = DBManger.dbGenericQuery(queryString: "DELETE FROM audioAttributes where id = '\(selectedId)' AND languageId = '\(languageId)'")
                        
                        for (indexOfID,id) in alreadyDownloadedAudioIds.enumerated(){
                            if id == selectedId{
                                alreadyDownloadedAudioIds.remove(at: indexOfID)
                            }
                        }
                        let result = DBManger.dbGenericQuery(queryString: "SELECT * FROM audioAttributes where nr = '\(nrNumber)' AND languageId = '\(languageId)'")
                        if result.count == 0{
                            _ = DBManger.dbGenericQuery(queryString: "DELETE FROM downloadedAudios where nr = '\(nrNumber)' AND languageId = '\(languageId)'")
                        }
                        
                    }else{
                        
                        _ = DBManger.dbGenericQuery(queryString: "UPDATE  downloadedAudios SET isFave = 'false' where nr = '\(nrNumber)' AND languageId = '\(languageId)'")
                    }
                }
                self.willLoadDataOnCollectionView(languageId: selectedIndexpath.item == 0 ? 1 : 2)
            }
        }
        
     
    }
    
    func downloadAudioFromServer(soundDetails:AudioDetails,selectedFile:AudioAttributes,completionHandler:@escaping (Bool)->()){
        
        if let selectedIndexpath = self.languageSelectionMenu.collectionViewForMenu.indexPathsForSelectedItems?.first,let selectedId = selectedFile.id{
            if let urlString = selectedFile.fileURL,let url = URL(string: urlString){
                ShowHud.show(loadingMessage: Vocabulary.getWordFromKey(key: "hud.downloading").capitalized)
                URLSession.shared.dataTask(with: url, completionHandler: { (soundData, response, error) in
                    if error == nil,soundData != nil   {
                        //print(String(data: data!, encoding: .utf8)!)
                        if let httpStatus = response as? HTTPURLResponse  { // checks http errors
                            if httpStatus.statusCode == 200{
                                
                                DispatchQueue.main.async{
                                    
                                    
                                    var nrNumber = 0
                                    if let val = soundDetails.nr{
                                        nrNumber = val
                                    }
                                    var languageId = 1
                                    if let val = soundDetails.languageId{
                                        languageId = val
                                    }
                                    var title = "N/A"
                                    if let val = soundDetails.title{
                                        title = val
                                    }
                                    
                                    let downloadedResult = DBManger.dbGenericQuery(queryString: "SELECT * FROM downloadedAudios WHERE nr = '\(nrNumber)' AND languageId = '\(languageId)'")
                                    
                                    var query1 = ""
                                    if downloadedResult.count == 0{
                                        query1 = "INSERT INTO downloadedAudios(nr,languageId,title,isPaid) VALUES('\(nrNumber)','\(languageId)','\(title)','\(soundDetails.isPaid)')"
                                        
                                    }else{
                                        
                                        query1 = "UPDATE downloadedAudios SET nr = '\(nrNumber)',languageId = '\(languageId)',title = '\(title)',isPaid = '\(soundDetails.isPaid)' WHERE nr = '\(nrNumber)' AND languageId = '\(languageId)'"
                                        
                                    }
                                    _ = DBManger.dbGenericQuery(queryString: query1)
                                    
                                    _ = DBManger.dbGenericQuery(queryString: "DELETE FROM audioAttributes where id='\(selectedId)'")
                                    
                                    var gender:Gender = .man
                                    if let val = selectedFile.gender{
                                        gender = val
                                    }
                                    var filesOrgName = "N/A"
                                    if let val = selectedFile.fileOriginalName{
                                        filesOrgName = val
                                    }
                                    
                                    var duration = "0.0 min"
                                    if let val = selectedFile.duration{
                                        duration = val
                                    }
                                    
                                    var stringToBeAppended = "".randomString(length: 10)
                                    let seperatedComp = urlString.components(separatedBy: "/")
                                    if let lastString = seperatedComp.last{
                                        
                                        stringToBeAppended = lastString
                                    }
                                    
                                    let fileManager = FileManager.default
                                    let localPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(stringToBeAppended)
                                    
                                    fileManager.createFile(atPath: localPath as String, contents: soundData, attributes: nil)
                                    
                                    let query2 = "INSERT INTO audioAttributes(nr,id,gender,languageId,fileOriginalName,duration,fileURL,localPath) VALUES('\(nrNumber)','\(selectedId)','\(String(describing: gender))','\(languageId)','\(filesOrgName)','\(duration)','\(urlString)','\(localPath)')"
                                    _ = DBManger.dbGenericQuery(queryString: query2)
                                    
                                    alreadyDownloadedAudioIds.append(selectedId)
                                    completionHandler(true)
                                    
                                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "meditationview.med_downloaded"))
                                }
                            }
                        }
                    }else{
                        DispatchQueue.main.async{
                            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
                        }
                    }
                    
                    DispatchQueue.main.async{
                        ShowHud.hide()
                        self.willLoadDataOnCollectionView(languageId: selectedIndexpath.item == 0 ? 1 : 2)
                    }
                }).resume()
                
                
             
                
        }}
    
    }
    
    
}

class CellForMeditation:BaseCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{

    
    var dataSource:DataSourceForCollectionView?
    let reUsableId = "cellId1"
    let favAndDownlaodedCell = "cell2"
    let headerId = "headerID"
    let heightOfHeaderView:CGFloat = DeviceType.isIpad() ? 65 : 40
    
    lazy var collectionView:UICollectionView={
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        flow.sectionHeadersPinToVisibleBounds = false
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        cv.backgroundColor = .clear
        cv.register(CellForSoundDetails.self, forCellWithReuseIdentifier:self.reUsableId)
        cv.register(HeaderForMeditationCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier:self.headerId)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    var cellIndex:Int?{
        didSet{
            self.collectionView.reloadData()
        }
    }
    override func setUpCell() {
        self.backgroundColor = .clear
       
        self.addSubview(collectionView)
        self.addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        self.addConstraintsWithFormat("V:|[v0]|", views: collectionView)
    }
    
    //MARK: Collection view delegates 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
       
        if cellIndex == 0{
             return CGSize(width: self.collectionView.frame.width, height:heightOfHeaderView)
        }else{
             return CGSize(width: self.collectionView.frame.width, height:0)
        }
       
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       
       
        collectionView.removeNoDataLabel()
        if let dataSourceValue = dataSource{
            if cellIndex == 0{
              
                if dataSourceValue.favouriteAudio?.count == 0 && dataSourceValue.downloadedAudio?.count == 0{
                    collectionView.showNoDataFound(msg: Vocabulary.getWordFromKey(key: "mediationview.label.no_downloaded"))
                    return 0
                }else if dataSourceValue.favouriteAudio?.count == 0 || dataSourceValue.downloadedAudio?.count == 0{
                    return 1
                }else{
                    return 2
                }
                
            }else if cellIndex == 1,dataSourceValue.downloadableAudio?.count == 0{
                 collectionView.showNoDataFound(msg: Vocabulary.getWordFromKey(key: "meditationview.label.no_downloads"))
            }
        }
        
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if let cell = cellIndex{
            if cell == 0{ // my meditation
              
                if let dataSourceValue = dataSource{
                  
                    if dataSourceValue.favouriteAudio?.count == 0 && dataSourceValue.downloadedAudio?.count == 0{
                        return 0
                    }else if dataSourceValue.favouriteAudio?.count == 0 || dataSourceValue.downloadedAudio?.count == 0{
                     
                        if let count = dataSourceValue.favouriteAudio?.count,count != 0{
                            return count
                        }else if let count = dataSourceValue.downloadedAudio?.count,count != 0{
                            return count
                        }
                   
                    }else if section == 0,let count = dataSourceValue.favouriteAudio?.count{
                        return count
                    }else if section == 1,let count = dataSourceValue.downloadedAudio?.count{
                        return count
                    }
                }
                return 0
            }else if cell == 1{ // downladable
                if let count = dataSource?.downloadableAudio?.count{
                    return count
                }
                return 0
            }
        }
        
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height:heightOfCellTodisplaySoundDetails)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reUsableId, for: indexPath) as! CellForSoundDetails
        if let cellIndex = cellIndex{
           
            if cellIndex == 0{
                
                var dataTobeShow = [AudioDetails]()
                if let dataSourceValue = dataSource{
                    if dataSourceValue.favouriteAudio?.count == 0 || dataSourceValue.downloadedAudio?.count == 0{
                        if let count = dataSourceValue.favouriteAudio?.count,count != 0{
                            dataTobeShow = dataSourceValue.favouriteAudio!
                            cell.cellTypeInTheSection = .favourite
                        }else if let count = dataSourceValue.downloadedAudio?.count,count != 0{
                            dataTobeShow = dataSourceValue.downloadedAudio!
                            cell.cellTypeInTheSection = .downloaded
                            
                        }
                    }else if indexPath.section == 0{
                        dataTobeShow = dataSourceValue.favouriteAudio!
                        cell.cellTypeInTheSection = .favourite
                    }else if indexPath.section == 1{
                        dataTobeShow = dataSourceValue.downloadedAudio!
                        cell.cellTypeInTheSection = .downloaded
                    }
                }
                cell.soundDetails = dataTobeShow[indexPath.item]
               
            }  else if cellIndex == 1{
                if let downloadableSource = self.dataSource?.downloadableAudio{
                    cell.cellTypeInTheSection = .downloadable
                    cell.soundDetails = downloadableSource[indexPath.item]
                }
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.headerId, for: indexPath) as! HeaderForMeditationCell
        if cellIndex == 0{
           
            if let dataSourceValue = dataSource{
                if let favCount = dataSourceValue.favouriteAudio?.count,let downCount = dataSourceValue.downloadedAudio?.count,favCount != 0,downCount != 0{
                    if indexPath.section == 0{
                        cell.titleLabel.text = Vocabulary.getWordFromKey(key: "meditationview.favourite").uppercased()
                    }else{
                        cell.titleLabel.text = Vocabulary.getWordFromKey(key: "meditationview.label.downloaded").uppercased()
                    }
                }else if let favCount = dataSourceValue.favouriteAudio?.count,favCount != 0{
                    cell.titleLabel.text = Vocabulary.getWordFromKey(key: "meditationview.favourite").uppercased()
                }else if let downCount = dataSourceValue.downloadedAudio?.count,downCount != 0{
                    cell.titleLabel.text = Vocabulary.getWordFromKey(key: "meditationview.label.downloaded").uppercased()
                }
            }
            
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return DeviceType.isIpad() ? 15 : 5
    }
}

class CellForSoundDetails:BaseCell,customAlertDelegates{
   
   
    var cellTypeInTheSection:CellType?
    var soundDetails:AudioDetails?{
        didSet{
            
            if soundDetails!.isPaid , !String.has_full_access(){
                lockImageView.isHidden = false
            }else{
                lockImageView.isHidden = true
            }
            
            if let title = soundDetails?.title{
                self.titleForSoundLabel.text = title.capitalized
            }
            if let subTitle = soundDetails?.subTitle{
                self.detailsLabel.text = subTitle.capitalized
            }
            if cellTypeInTheSection == .favourite || cellTypeInTheSection == .downloaded{
                self.buttonOnCell.setImage(#imageLiteral(resourceName: "remove"), for: .normal)
            }else if cellTypeInTheSection == .downloadable{
                self.buttonOnCell.setImage(#imageLiteral(resourceName: "downloads_blue"), for: .normal)
            }
        }
    }
    
    let containerView:UIView={
        let view = UIView()
        view.backgroundColor = .white
        view.showShadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = DeviceType.isIpad() ? 34 : 17
        return view
    }()
    
    var titleForSoundLabel:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 17.5 : 15.5)
        label.textColor = UIColor.rgb(24, green: 16, blue: 143)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.text = Vocabulary.getWordFromKey(key: "general.no_details").capitalized
        
        return label
    }()
    
    var detailsLabel:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 16 : 14, weight: UIFont.Weight(rawValue: -0.5))
        label.textColor = UIColor.rgb(24, green: 16, blue: 143)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = Vocabulary.getWordFromKey(key: "general.no_details").capitalized
        label.backgroundColor = .clear
        return label
    }()
    
    lazy var buttonOnCell:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        button.addTarget(self, action: #selector(self.didClickedOnCellButton), for: .touchUpInside)
        return button
    }()
    
    let lockImageView:UIImageView={
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "lock").withRenderingMode(.alwaysTemplate)
        iv.tintColor = UIColor.getThemeTextColor()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override func setUpCell() {
        
        self.contentView.addSubview(containerView)
        let paddingAtRightLeft:CGFloat = self.frame.width/15
        self.contentView.addConstraintsWithFormat("H:|-\(paddingAtRightLeft)-[v0]-\(paddingAtRightLeft)-|", views: containerView)
        self.contentView.addConstraintsWithFormat("V:|[v0]-5-|", views: containerView)
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(self.didTapped))
        self.contentView.addGestureRecognizer(tapped)
        

        
        self.contentView.addSubview(titleForSoundLabel)
        self.addSubview(detailsLabel)
        self.contentView.addSubview(buttonOnCell)
        self.containerView.addSubview(lockImageView)
        
        let sizeOfLockImage:CGFloat = DeviceType.isIpad() ? 25 : 20
        
        lockImageView.heightAnchor.constraint(equalToConstant: sizeOfLockImage).isActive = true
        lockImageView.widthAnchor.constraint(equalToConstant: sizeOfLockImage).isActive = true
        lockImageView.leftAnchor.constraint(equalTo: self.containerView.leftAnchor, constant: 16).isActive = true
        lockImageView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor, constant: 0).isActive = true
        
        
        let sizeOfButton:CGFloat = DeviceType.isIpad() ? 55 : 45
        
        self.buttonOnCell.rightAnchor.constraint(equalTo: self.containerView.rightAnchor, constant: -10).isActive = true
        self.buttonOnCell.heightAnchor.constraint(equalToConstant: sizeOfButton).isActive = true
        self.buttonOnCell.widthAnchor.constraint(equalToConstant: sizeOfButton).isActive = true
        self.buttonOnCell.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor, constant: 0).isActive = true
        
        self.titleForSoundLabel.rightAnchor.constraint(equalTo: self.buttonOnCell.leftAnchor, constant: -5).isActive = true
        self.titleForSoundLabel.leftAnchor.constraint(equalTo: self.containerView.leftAnchor, constant: sizeOfButton).isActive = true
        self.titleForSoundLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 5).isActive = true
        self.titleForSoundLabel.heightAnchor.constraint(equalTo: self.containerView.heightAnchor, multiplier: 0.4).isActive = true
        
        self.detailsLabel.rightAnchor.constraint(equalTo: self.buttonOnCell.leftAnchor, constant: -5).isActive = true
        self.detailsLabel.leftAnchor.constraint(equalTo: self.containerView.leftAnchor, constant: sizeOfButton).isActive = true
        self.detailsLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -5).isActive = true
        self.detailsLabel.heightAnchor.constraint(equalTo: self.containerView.heightAnchor, multiplier: 0.4).isActive = true
        
        
        
        
        
    }
    
    
    func doOperation(file:AudioAttributes){
        if let soundDetailsToBeSet = soundDetails{
            
            if cellTypeInTheSection == .favourite{
                referenceOfMeditationView?.didTapOnSoundCell(soundDetails: soundDetailsToBeSet, selectedFile:file, operationType: .removeFromFav)
            }else if cellTypeInTheSection == .downloaded{
              
                referenceOfMeditationView?.didTapOnSoundCell(soundDetails: soundDetailsToBeSet, selectedFile:file, operationType: .removeFromDownloaded)
            } else if cellTypeInTheSection == .downloadable{
                if Reachability.isAvailable(){
                    buttonOnCell.setImage(UIImage(named:"downloading"), for: .normal)
                    referenceOfMeditationView?.didTapOnSoundCell(soundDetails: soundDetailsToBeSet, selectedFile:file, operationType: .didTapToDownload)
                    
                }else{
                    
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.no_connection"))
                }
                
            }
    }
        
    }
    
    @objc func didClickedOnCellButton(sender:UIButton){
        
        if !lockImageView.isHidden,cellTypeInTheSection == .downloadable{
                self.showSubscribeAlert()
                return
        }
        
        
        
        if let files = soundDetails?.files{
            if files.count == 1 || self.cellTypeInTheSection == .favourite{
                self.doOperation(file: files.first!)
                
            }else if files.count > 1{
                var headerTitle = Vocabulary.getWordFromKey(key: "meditationview.popup.title").capitalized
                
                if cellTypeInTheSection == .favourite || cellTypeInTheSection == .downloaded{
                    headerTitle = Vocabulary.getWordFromKey(key: "general.remove").capitalized
                }else if cellTypeInTheSection == .downloadable{
                    headerTitle = Vocabulary.getWordFromKey(key: "meditationview.popup.download").capitalized
                 }
               
                self.showOptions(title: headerTitle,completionHandler: { (gender) in
                    
                    var fileToSend:AudioAttributes?
                    
                    if gender == "man"{
                        
                        for att1 in files{
                            if att1.gender == .man{
                                fileToSend = att1
                               break
                            }
                        }
                        
                    }else{
                        
                        for att1 in files{
                            if att1.gender == .woman{
                                fileToSend = att1
                                break
                            }
                        }
                    }
                    
                    if fileToSend != nil{
                        self.doOperation(file: fileToSend!)
                    }
                    
                })
            }
        }
        
    }
    
    @objc func didTapped(){
      
        if !lockImageView.isHidden{
            self.showSubscribeAlert()
            return
        }
      
        if let soundDetailsToBeSet = soundDetails{
            if (cellTypeInTheSection == .favourite || cellTypeInTheSection == .downloaded){
                
                var fileToSend:AudioAttributes?
                if let files = soundDetails?.files{
                    if files.count == 1{
                        referenceOfMeditationView?.didTapOnSoundCell(soundDetails: soundDetailsToBeSet, selectedFile: files.first!, operationType: .play)
                    }else if files.count > 1{
                        
                        
                        self.showOptions(title: Vocabulary.getWordFromKey(key: "meditationview.play"),completionHandler: { (gender) in
                            
                            if gender == "man"{
                                
                                for att1 in files{
                                    if att1.gender == .man{
                                        fileToSend = att1
                                        break
                                    }
                                }
                            }else{
                                
                                for att1 in files{
                                    if att1.gender == .woman{
                                        fileToSend = att1
                                        break
                                    }
                                }
                            }
                            if fileToSend != nil{
                                referenceOfMeditationView?.didTapOnSoundCell(soundDetails: soundDetailsToBeSet, selectedFile: fileToSend!, operationType: .play)
                            }
                            
                        })
                    }
                }
                
                
            }else{
                self.didClickedOnCellButton(sender: buttonOnCell)
            }
        }
    }
    
    func showOptions(title:String,completionHandler:@escaping (String)->()){
        
      let actionSheetController = UIAlertController(title:"", message: "\(Vocabulary.getWordFromKey(key: "meditationview.popup.title.select_gender"))", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: Vocabulary.getWordFromKey(key: "general.cancel"), style: .cancel) { action -> Void in
           
        }
        actionSheetController.addAction(cancelActionButton)
        
         var maleExist = false
         var femaleExist = false
         if let files = soundDetails?.files{
            
            
            for att1 in files{
                
                if let id = att1.id{
                    
                    if cellTypeInTheSection == .downloadable{
                        if alreadyDownloadedAudioIds.contains(id){
                            if att1.gender == .man{
                                maleExist = true
                            }else {
                                femaleExist = true
                            }
                        }
                    }
                }
            }
            
            if !maleExist{
                let maleActionButton = UIAlertAction(title: Vocabulary.getWordFromKey(key: "download.sound.choice.male_voice"), style: .default) { action -> Void in
                    completionHandler("man")
                }
                
                actionSheetController.addAction(maleActionButton)
                
            }
            if !femaleExist{
                let femlaleActionButton = UIAlertAction(title: Vocabulary.getWordFromKey(key: "download.sound.choice.female_voice"), style: .default) { action -> Void in
                    completionHandler("woman")
                }
                actionSheetController.addAction(femlaleActionButton)
            }
        }
        if DeviceType.isIpad(){
             actionSheetController.modalPresentationStyle = .popover
            if let presenter = actionSheetController.popoverPresentationController,let medView = referenceOfMeditationView {
                presenter.sourceView = medView.view
                presenter.permittedArrowDirections = .init(rawValue: 0)
                presenter.sourceRect = CGRect(x: (medView.view.frame.width/2)-100, y: (medView.view.frame.height/2)-250, width: 200, height: 500)
            }
        }
        referenceOfMeditationView?.present(actionSheetController, animated: true, completion: nil)
        
        
        
    
    }
  
    func showSubscribeAlert(){
        
        InAppManager.shared.loadProducts(operation: .buy)
        
        return
    }
    
    func didTappedCustomAletButton(selectedIndex: Int, title: String, userInfo: [String : AnyObject]?) {
        if selectedIndex == 1{
            if userInfo?["subscribe"] != nil{
              
                InAppManager.shared.referenceOfMeditationView = referenceOfMeditationView
                InAppManager.shared.loadProducts(operation: .buy)
                return
            }
            
            if let info = userInfo,let file = info["file"] as? AudioAttributes,let soundDetailsToBeSet = soundDetails{
                
                referenceOfMeditationView?.didTapOnSoundCell(soundDetails: soundDetailsToBeSet, selectedFile:file, operationType: .didTapToBuy)
                self.buttonOnCell.setImage(UIImage(named:"downloading"), for: .normal)
            }
        }
    }

}

class HeaderForMeditationCell:UICollectionReusableView{
    
    var bgImage:UIImageView={
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .clear
        return iv
    }()
    
    let titleLabel:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = UIColor.getYellowishColor()
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : 16, weight: UIFont.Weight(rawValue: 0))
        label.text = "N/A"
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpHeaderViews()
        
    }
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpHeaderViews(){
     
        self.addSubview(bgImage)
        bgImage.addSubview(titleLabel)
       
        self.addConstraintsWithFormat("H:|[v0]|", views: bgImage)
        self.addConstraintsWithFormat("V:|[v0]|", views: bgImage)
        
        bgImage.addConstraintsWithFormat("H:|[v0]|", views: titleLabel)
        bgImage.addConstraintsWithFormat("V:|[v0]|", views: titleLabel)
    }
    
}








