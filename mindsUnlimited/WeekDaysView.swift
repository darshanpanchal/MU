//
//  WeakDaysViewForReminder.swift
//  mindsUnlimited
//
//  Created by IPS on 27/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit

class WeekDaysView:UIView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var referenceOfReminderView:ReminderSettings?
    
    var daysNames = [["MON":"0"],["TUE":"0"],["WED":"0"],["THU":"0"],["FRI":"0"],["SAT":"0"],["SUN":"0"],["ALL":"0"]]{
        didSet{
            self.collectionViewForDays.reloadData()
        }
    }
    
    let reUsableId = "cellId"
    
    lazy var collectionViewForDays:UICollectionView={
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        cv.backgroundColor = UIColor.init(white: 1, alpha: 0)
        cv.register(CollectionViewCellForWeekDays.self, forCellWithReuseIdentifier:self.reUsableId)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpViews(){
        self.addSubview(collectionViewForDays)
        self.addConstraintsWithFormat("H:|[v0]|", views: collectionViewForDays)
        self.addConstraintsWithFormat("V:|[v0]|", views: collectionViewForDays)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return daysNames.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reUsableId, for: indexPath) as! CollectionViewCellForWeekDays
        
        
        let dict = daysNames[indexPath.item]
        if let name = dict.keys.first,let isActive = dict.values.first,let value = Int(isActive){
            
            cell.dayNameLabel.text = Vocabulary.getWordFromKey(key: name.lowercased()).uppercased()
            
            if value == 0 {
                cell.backgroundColor = .white
                cell.dayNameLabel.textColor = UIColor.getThemeTextColor()
              
            }else{
                cell.backgroundColor = UIColor.switchColor()
                cell.dayNameLabel.textColor = .white
            }
            
        }
      
        return cell
    }
    let interSpacing:CGFloat = DeviceType.isIpad() ? 40 : (UIScreen.main.bounds.height < 481 ? 10 : 20)
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
        return CGSize(width:(collectionView.frame.width/4)-interSpacing, height: (collectionView.frame.height/2)-interSpacing)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return interSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(interSpacing/2, 0, 0, 4)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
       
        func selectAll(value:String = "1"){
             daysNames = [["MON":value],["TUE":value],["WED":value],["THU":value],["FRI":value],["SAT":value],["SUN":value],["ALL":value]]
        }
        
        var dict = daysNames[indexPath.item]
        if let name = dict.keys.first,let isActive = dict.values.first,let value = Int(isActive){
            dict[name] = String(value == 0 ? 1 : 0)
        }
        daysNames[indexPath.item] = dict
        
        var counter = 0
        for dict1 in daysNames{
            if let name = dict1.keys.first,name.lowercased().removeWhiteSpaces() != "all",let isActive = dict1.values.first,let value = Int(isActive),value == 1{
                counter += 1
                
            }
        }
        
        if counter == 7 && indexPath.item == 7{
             selectAll(value: "0")
        }else if indexPath.item == 7 || counter == 7{
            selectAll()
        } else{
            daysNames[7] = ["ALL":"0"]
        }
        
       
        collectionView.reloadData()
        self.referenceOfReminderView?.didSelectWeekDay(selectedArr: daysNames)
    
    }

}

class CollectionViewCellForWeekDays:BaseCell{
    
    let dayNameLabel:UILabel={
        let label = UILabel()
        label.text = "N/A"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getThemeTextColor()
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 18 : 14)
        return label
    }()
    
    override func setUpCell() {
        
        self.showShadow()
        self.layer.cornerRadius = DeviceType.isIpad() ? 25 : 17
        self.backgroundColor = .white
        
        self.addSubview(dayNameLabel)
        self.addConstraintsWithFormat("H:|[v0]|", views: dayNameLabel)
        self.addConstraintsWithFormat("V:|[v0]|", views: dayNameLabel)
    }
}



