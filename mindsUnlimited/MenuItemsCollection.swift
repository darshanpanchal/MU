//
//  MenuItemsCollection.swift
//  campus.
//
//  Created by ips on 31/01/17.
//  Copyright © 2017 Dilip manek. All rights reserved.
//

protocol MenuItemDelegate:class {
    func didSelectItemAtIndexPath(selectedCellInfo:DataSourceForMenuCollection)
}

import UIKit
enum MenuType{
    case social
    case language
    case myMeditation
}

class MenuItemsCollection: UIView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var typeOfMenu:MenuType?
    var delegate:MenuItemDelegate?
    var menuDataSource:[DataSourceForMenuCollection]?{
        didSet{
            self.collectionViewForMenu.reloadData()
            let indexPathSet = IndexPath(row: 0, section: 0)
            self.collectionViewForMenu.selectItem(at: indexPathSet, animated: false, scrollPosition: .left)
            
        }
    }
    
    let reUsableId = "cellId"
    
    lazy var collectionViewForMenu:UICollectionView={
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        cv.backgroundColor = UIColor.init(white: 0, alpha: 0)
        cv.register(CollectionViewCellForMenu.self, forCellWithReuseIdentifier:self.reUsableId)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        return cv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setUpCollectionViewDesign()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpCollectionViewDesign() {
        self.addSubview(self.collectionViewForMenu)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.collectionViewForMenu)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.collectionViewForMenu)
   }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = menuDataSource?.count  {
                return count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reUsableId, for: indexPath) as! CollectionViewCellForMenu
        cell.cellType = typeOfMenu
        cell.cellAttributes = self.menuDataSource?[indexPath.row]
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        let cellWidth:CGFloat = self.frame.width / CGFloat(self.menuDataSource!.count)
       
        return CGSize(width:cellWidth, height: self.frame.height)
    
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedCellAttributes = menuDataSource![indexPath.item]
        delegate?.didSelectItemAtIndexPath(selectedCellInfo: selectedCellAttributes)
    }
    
}

class CollectionViewCellForMenu:UICollectionViewCell{
    
    override var isSelected: Bool{
        didSet{
            if cellType != .social{
                 self.highloghtColorOfCell()
            }
        }
    }
    var yPosOfImageView:NSLayoutConstraint?
    var heightOfImageView:NSLayoutConstraint?
    var widthOfImageView:NSLayoutConstraint?
    var cellType:MenuType? = .social{
        didSet{
            if cellType == .myMeditation{
                labelTitle.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 17 : 14, weight: UIFont.Weight(rawValue: 0))
                self.highloghtColorOfCell()
                self.yPosOfImageView?.constant = -11.5
                self.heightOfImageView?.constant = DeviceType.isIpad() ? 65 : 50
                self.widthOfImageView?.constant = DeviceType.isIpad() ? 65 : 50
                self.layer.cornerRadius = 10
                self.labelTitle.textColor = .white
                
            }else if cellType == .social{
                self.backgroundColor = UIColor(white: 0, alpha: 0)
                self.yPosOfImageView?.constant = 0
                self.heightOfImageView?.constant = DeviceType.isIpad() ? 60 : 50
                self.widthOfImageView?.constant = DeviceType.isIpad() ? 60 : 50
            
            }else if cellType == .language{
                labelTitle.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 20 : 15, weight: UIFont.Weight(rawValue: 0))
                self.layoutIfNeeded()
                for const in self.labelTitle.constraints{
                    const.isActive = false
                }
                self.layer.cornerRadius = 10
                self.imageViewForCell.removeFromSuperview()
              
                self.addConstraintsWithFormat("H:|[v0]|", views: self.labelTitle)
                self.addConstraintsWithFormat("V:|[v0]|", views: self.labelTitle)
                
                self.layoutIfNeeded()
                
                self.highloghtColorOfCell()
            }
        }
    }
    
    var cellAttributes:DataSourceForMenuCollection?{
        didSet{
            if let imageName = cellAttributes?.imageName{
                imageViewForCell.image = UIImage(named:imageName)
                if cellType != .social{
                    self.highloghtColorOfCell()
                }
            }
            if let title = cellAttributes?.titleForCell  {
                labelTitle.text = title
            }
        }
    }
   
    
    lazy var labelTitle:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 17 : 14, weight: UIFont.Weight(rawValue: 0))
        label.textColor = UIColor.getThemeTextColor()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        return label
    }()
    
    let imageViewForCell:UIImageView={
        let iv = UIImageView()
        iv.layer.cornerRadius = 8
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpCell()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func highloghtColorOfCell(){
        self.imageViewForCell.image = self.imageViewForCell.image?.withRenderingMode(.alwaysTemplate)
        if cellType == .myMeditation || cellType == .language{
            if isSelected{
                self.imageViewForCell.tintColor = UIColor.getThemeTextColor()
                self.labelTitle.textColor = UIColor.getThemeTextColor()
            }else{
                self.imageViewForCell.tintColor = nil
                self.labelTitle.textColor = .white
                if let imageName = cellAttributes?.imageName{
                    imageViewForCell.image = UIImage(named:imageName)
                }
            }
        }else{}
    }
    
    func setUpCell() {
       
        self.addSubview(imageViewForCell)
        self.addSubview(labelTitle)
     
        heightOfImageView =  NSLayoutConstraint(item: imageViewForCell, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 40)
        widthOfImageView = NSLayoutConstraint(item: imageViewForCell, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 40)
        
        self.yPosOfImageView = NSLayoutConstraint(item: imageViewForCell, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.addConstraints([NSLayoutConstraint(item: imageViewForCell, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),self.yPosOfImageView!,heightOfImageView!,widthOfImageView!])
        self.addConstraintsWithFormat("H:|[v0]|", views: labelTitle)
        
        self.labelTitle.topAnchor.constraint(equalTo: imageViewForCell.bottomAnchor, constant: 5).isActive = true
         self.labelTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
}

class DataSourceForMenuCollection:NSObject{
    var imageName:String?
    var isEnabled:Bool = true
    var titleForCell:String?
    var uniqueId:String?
}
