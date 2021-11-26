//
//  StatisticsView.swift
//  mindsUnlimited
//
//  Created by IPS on 08/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit

class StatisticsView: GeneralViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //Class properties
    let cellId1 = "cellId1"
    let cellId2 = "cellId2"
    let cellId3 = "cellId3"
    lazy var collectionView:UICollectionView={
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        cv.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        cv.backgroundColor = .clear
        cv.register(CellforStatistic.self, forCellWithReuseIdentifier:self.cellId1)
        cv.register(CellforStatisticImage.self, forCellWithReuseIdentifier:self.cellId2)
        cv.register(HeaderForStatisticCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.cellId3)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        return cv
    }()
    
    var myStatistics:[Statistics]?
    var groupStatistics:[Statistics]?
    var groupMemberStatstics:[Statistics]?
    
    //Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "general.title.statistics").uppercased()
        self.setUpViews()
        self.getStatisticsFromServer()
        
    }
    
    //Other methods
    
    func setUpViews(){
      
        let rightLeftPadding:CGFloat = DeviceType.isIpad() ? 30 : 20
        self.backgroudImageView.addSubview(collectionView)
        self.backgroudImageView.addConstraintsWithFormat("H:|-\(rightLeftPadding)-[v0]-\(rightLeftPadding)-|", views: collectionView)
        self.collectionView.topAnchor.constraint(equalTo: self.customNavigationImageView.bottomAnchor, constant: 0).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.backgroudImageView.bottomAnchor, constant: 0).isActive = true
   
    }
    
    override func backButtonActionHandeler(){
        self.popToHomeView()
    }
    
    
    
    func getStatisticsFromServer(){
        
        
        if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject], let userId = userDetails["Id"]{
            
            if Reachability.isAvailable(){
                
                
                func getDataFromServer(){
                    let queryString = "/users/\(userId)/statistics"
                    ApiRequst.doRequest(requestType: .GET, queryString: queryString, parameter: nil, completionHandler: { (json) in
                        if let myStat = json["Me"] as? [String:AnyObject]{
                            
                            var avgDay = 0
                            var avgWeek = 0
                            var total = 0
                            
                            if let val = myStat["AverageDay"] as? Int{
                                avgDay = val
                            }
                            if let val = myStat["AverageWeek"] as? Int{
                                avgWeek = val
                            }
                            if let val = myStat["Total"] as? Int{
                                total = val
                            }
                            
                            let statisticDay = Statistics(points: avgDay, name: "day", userId: 0)
                            let statisticWeek = Statistics(points: avgWeek, name: "week", userId: 0)
                            let statisticTotal = Statistics(points: total, name: "total", userId: 0)
                            self.myStatistics = [statisticDay,statisticWeek,statisticTotal]
                            
                        }
                        if let groupStat = json["Group"] as? [String:AnyObject]{
                            var avgDay = 0
                            var avgWeek = 0
                            var total = 0
                            
                            if let val = groupStat["AverageDay"] as? Int{
                                avgDay = val
                            }
                            if let val = groupStat["AverageWeek"] as? Int{
                                avgWeek = val
                            }
                            if let val = groupStat["Total"] as? Int{
                                total = val
                            }
                            
                            let statisticDay = Statistics(points: avgDay, name: "day", userId: 0)
                            let statisticWeek = Statistics(points: avgWeek, name: "week", userId: 0)
                            let statisticTotal = Statistics(points: total, name: "total", userId: 0)
                            self.groupStatistics = [statisticDay,statisticWeek,statisticTotal]
                        }
                        
                        if let groupMembersStat = json["Rewards"] as? [[String:AnyObject]]{
                            
                            var grouStatTempContainer = [Statistics]()
                            var myStat:Statistics?
                            for object in groupMembersStat{
                                var name = "N/A"
                                var points = 0
                                var userID = 0
                                
                                if let value = object["Name"] as? String{
                                    name = value
                                }
                                if let value = object["Points"] as? Int{
                                    points = value
                                }
                                if let value = object["UserId"] as? Int{
                                    userID = value
                                }
                                
                                
                                let statistic = Statistics(points: points, name: name, userId: userID)
                                
                                if name.lowercased().removeWhiteSpaces() == "me"{
                                    myStat = statistic
                                }else{
                                    grouStatTempContainer.append(statistic)
                                }
                            }
                            if let myStatVal = myStat{
                                grouStatTempContainer.insert(myStatVal, at: 0)
                            }
                            
                            
                            
                            self.groupMemberStatstics = grouStatTempContainer
                        }
                        DispatchQueue.main.async(execute: {
                            self.collectionView.reloadData()
                        })
                    })
                }
            
                if let offlineStoredStatus = UserDefaults.standard.object(forKey: "unSyncedSongs") as? [[String:Any]]{
                    
                    UserDefaults.standard.removeObject(forKey: "unSyncedSongs")
                    ApiRequst.doRequest(requestType: .POST, queryString: "users/\(userId)/statistics/multiple", parameter: ["Statistics":offlineStoredStatus as AnyObject], showHUD: true, completionHandler: { (json) in
                            getDataFromServer()
                    })
             
                }else{
                    getDataFromServer()
                }
          
            }else{
             
                self.collectionView.isHidden = true
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.no_connection"))
                
                self.view.showNoDataFound(msg:  Vocabulary.getWordFromKey(key: "general.no_connection"))
            }
        }
    }
    
    //MARK: Collection view Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject],userDetails["groupCode"] != nil,Reachability.isAvailable(){
                return 2
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if var userDetails = UserDefaults.standard.object(forKey: "userDetails") as? [String:AnyObject],userDetails["groupCode"] != nil{
            if section == 0 {
                return 2
            }else if let count = self.groupMemberStatstics?.count{
                return count
            }
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if indexPath.section == 0{
             return CGSize(width: collectionView.frame.width, height:DeviceType.isIpad() ? 245 : 180)
        }else{
            let size =  (collectionView.frame.width/3)-(DeviceType.isIpad() ? 80 : 20)
            return CGSize(width:size,height: size)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.cellId3, for: indexPath) as! HeaderForStatisticCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 && (indexPath.item == 0 || indexPath.item == 1){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId1, for: indexPath) as! CellforStatistic
            cell.labelHeader.text =  Vocabulary.getWordFromKey(key: indexPath.item == 0 ? "statistic.label.me" : "general_group").uppercased()
            
            if indexPath.item == 0,let myStatValue = self.myStatistics,myStatValue.count == 3{
                
                cell.statics = myStatValue
                cell.labelTotal.text = Vocabulary.getWordFromKey(key: "statistic.label.total").uppercased()
                
            }else if indexPath.item == 1,let groupVal = self.groupStatistics,groupVal.count == 3{
             
                cell.statics = groupVal
                
                cell.labelTotal.text = Vocabulary.getWordFromKey(key: "statistic.label.average").uppercased() + " / \n" + Vocabulary.getWordFromKey(key: "statistic.label.total").uppercased()
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId2, for: indexPath) as! CellforStatisticImage
            
            if let membersVal = self.groupMemberStatstics{
                cell.statics = membersVal[indexPath.item]
                
            }
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0{
            return 0
        }else{
            return 30
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0{
                return CGSize(width: 0, height: 0)
        }else{
             return CGSize(width: collectionView.frame.width, height: 50)
        }
        
    }
   
    
}


class CellforStatistic:BaseCell{
    
    

    var statics:[Statistics]?{
        didSet{
        
            for (index,value) in statics!.enumerated(){
                labelsToShowStatValue[index].text = String(describing: value.points)
            }
        }
    }
    
    let labelHeader:UILabel={
        let label = UILabel()
        label.text =  Vocabulary.getWordFromKey(key: "statistic.label.me").uppercased()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getYellowishColor()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 22 : 16)
        return label
    }()
    
    let titleFont = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 15 : 13)
   
    lazy var labelAvgDay:UILabel={
        let label = UILabel()
       
        label.text =  Vocabulary.getWordFromKey(key: "statistic.label.average").uppercased() + " / \n" + Vocabulary.getWordFromKey(key: "statistic.label.day").uppercased()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getThemeTextColor()
        label.numberOfLines = 2
        label.font = self.titleFont
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    lazy var labelAvgWeek:UILabel={
        let label = UILabel()
        label.text =   Vocabulary.getWordFromKey(key: "statistic.label.average").uppercased() + " / \n" + Vocabulary.getWordFromKey(key: "statistic.label.week").uppercased()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getThemeTextColor()
        label.numberOfLines = 2
        label.font = self.titleFont
         label.adjustsFontSizeToFitWidth = true
        return label
    }()
    lazy var labelTotal:UILabel={
        let label = UILabel()
        label.text = "Loading..."
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getThemeTextColor()
        label.numberOfLines = 2
        label.font = self.titleFont
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var labelsToShowStatValue = [UILabel]()
    
    lazy var valueLabelsContainer:UIView={
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        var labels = [UILabel]()
        
        let heightOfTimes:CGFloat = 15
        
        for i in 0..<3{
            
            let timesLabel = UILabel()
            timesLabel.text =   Vocabulary.getWordFromKey(key: "statistic.label.times").capitalized
            timesLabel.textAlignment = .center
            timesLabel.translatesAutoresizingMaskIntoConstraints = false
            timesLabel.textColor = UIColor.getThemeTextColor()
            timesLabel.numberOfLines = 0
            timesLabel.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 15 : 13)
            view.addSubview(timesLabel)
            view.addConstraintsWithFormat("V:[v0(\(heightOfTimes))]|", views: timesLabel)
            labels.append(timesLabel)
        }
        view.addConstraintsWithFormat("H:|[v0(v1)]-3-[v1(v0)]-3-[v2(v0)]|", views: labels[0],labels[1],labels[2])
       
        let sizeOfCircle:CGFloat = DeviceType.isIpad() ? 90 : 60
        for i in 0..<3{
            
            let valueRoundLabel = UILabel()
            valueRoundLabel.text =   "00"
            valueRoundLabel.textAlignment = .center
            valueRoundLabel.layer.cornerRadius = sizeOfCircle/2
            valueRoundLabel.translatesAutoresizingMaskIntoConstraints = false
            valueRoundLabel.textColor = .black
            valueRoundLabel.backgroundColor = .white
            valueRoundLabel.numberOfLines = 0
            valueRoundLabel.layer.borderWidth = 2.5
            valueRoundLabel.layer.borderColor = UIColor.getYellowishColor().cgColor
            valueRoundLabel.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 19 : 17)
            valueRoundLabel.clipsToBounds = true
            
            self.labelsToShowStatValue.append(valueRoundLabel)
            view.addSubview(valueRoundLabel)
            
            valueRoundLabel.centerXAnchor.constraint(equalTo: labels[i].centerXAnchor, constant: 0).isActive = true
            valueRoundLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -heightOfTimes/2).isActive = true
            valueRoundLabel.heightAnchor.constraint(equalToConstant: sizeOfCircle).isActive = true
            valueRoundLabel.widthAnchor.constraint(equalToConstant: sizeOfCircle).isActive = true
       
        }
        return view
    }()
    
    
    let valueFont = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : 16)
    lazy var labelAvgDayValue:UILabel={
        let label = UILabel()
        label.text =  "0"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getThemeTextColor()
        label.numberOfLines = 0
        label.font = self.valueFont
        return label
    }()
    lazy var labelAvgWeekValue:UILabel={
        let label = UILabel()
        label.text =  "0"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getThemeTextColor()
        label.numberOfLines = 0
        label.font = self.valueFont
        return label
    }()
    lazy var labelTotalValue:UILabel={
        let label = UILabel()
        label.text =  "0"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getThemeTextColor()
        label.numberOfLines = 0
        label.font = self.valueFont
        return label
    }()
    
    
    override func setUpCell() {
        
        self.addSubview(labelHeader)
        self.addSubview(labelAvgDay)
        self.addSubview(labelAvgWeek)
        self.addSubview(labelTotal)
        self.addSubview(valueLabelsContainer)
        
        
        let heightOfHeader:CGFloat = DeviceType.isIpad() ? 65 : 50
        let heightOfAvgLabel:CGFloat = DeviceType.isIpad() ? 45 : 35
        
        self.addConstraintsWithFormat("H:|[v0]|", views: labelHeader)
        self.addConstraintsWithFormat("H:|[v0(v1)]-3-[v1(v2)]-3-[v2(v0)]|", views: labelAvgDay,labelAvgWeek,labelTotal)
        self.addConstraintsWithFormat("V:|[v0(\(heightOfHeader))]", views: labelHeader)
        
        labelAvgDay.topAnchor.constraint(equalTo: self.labelHeader.bottomAnchor, constant: 5).isActive = true
        labelAvgWeek.topAnchor.constraint(equalTo: self.labelHeader.bottomAnchor, constant: 5).isActive = true
        labelTotal.topAnchor.constraint(equalTo: self.labelHeader.bottomAnchor, constant: 5).isActive = true
        
        labelAvgDay.heightAnchor.constraint(equalToConstant: heightOfAvgLabel).isActive = true
        labelAvgWeek.heightAnchor.constraint(equalToConstant: heightOfAvgLabel).isActive = true
        labelTotal.heightAnchor.constraint(equalToConstant: heightOfAvgLabel).isActive = true
        
        self.addConstraintsWithFormat("H:|[v0]|", views: valueLabelsContainer)
        valueLabelsContainer.topAnchor.constraint(equalTo: self.labelTotal.bottomAnchor, constant: 2).isActive = true
        valueLabelsContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
    }
}
class CellforStatisticImage:BaseCell{
    
    var statics:Statistics?{
        didSet{
            
            
            if statics!.name.removeWhiteSpaces().lowercased() == "me"{
                titleLabal.text = Vocabulary.getWordFromKey(key: "statistic.label.me").uppercased()
                titleLabal.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 20 : 12)
            }else{
                titleLabal.text = statics!.name.capitalized
                titleLabal.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 20 : 12)
            }
            
            if statics!.points < 25{
                soundProgressImageView.image = UIImage(named:"statistic"+String(statics!.points))
            }else{
                soundProgressImageView.image = UIImage(named:"statistic"+"0")
            }
        }
    }
    
    
    lazy var soundProgressImageView:UIImageView={
        let iv = UIImageView()
        iv.tag = 20
        iv.image = UIImage(named:"statistic"+"0")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
    lazy var titleLabal:UILabel={
        let label = UILabel()
        label.text =  "Loading..."
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getThemeTextColor()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 20 : 12)
        return label
    }()
    
    
    override func setUpCell() {
     
        self.addSubview(soundProgressImageView)
        self.addSubview(titleLabal)
        let padding:CGFloat = DeviceType.isIpad() ? 60 : 15
        
        self.addConstraintsWithFormat("H:|-\(padding/2)-[v0]-\(padding/2)-|", views: soundProgressImageView)
        self.addConstraintsWithFormat("H:|[v0]|", views: titleLabal)
        self.addConstraintsWithFormat("V:|[v0]-3-[v1(\(padding))]|", views: soundProgressImageView,titleLabal)
    }
}


class HeaderForStatisticCell:UICollectionReusableView{
    
    
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
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpViews(){
        
        self.addSubview(seperator)
        self.addConstraintsWithFormat("H:|[v0]|", views: seperator)
        self.addConstraintsWithFormat("V:[v0(1.5)]", views: seperator)
        seperator.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        
        
    }
}







