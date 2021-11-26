//
//  BaseCell.swift
//  mindsUnlimited
//
//  Created by IPS on 13/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import Foundation
import UIKit

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpCell(){
    
    }
}
