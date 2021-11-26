//
//  Extensions.swift
//  campus.
//
//  Created by ips on 08/02/17.
//  Copyright © 2017 Dilip manek. All rights reserved.
//

import UIKit




var cashedImages = [String:UIImage]()

class ImageViewForURL:UIImageView{

     var imageUrl = ""
    
    public func imageFromServerURL(urlString: String) {
       
        self.image = #imageLiteral(resourceName: "cell_placeholder")
        self.stopLoadingView()
        self.imageUrl = urlString
        
        if let cashedImage = cashedImages[urlString]{
            self.image = cashedImage
            return
        }
        guard let url = URL(string: urlString) else {
            return
        }
        
        self.startLoadingView()
        URLSession.shared.dataTask(with:url , completionHandler: { (imageData, response, error) -> Void in
            
            if error != nil {
                return
            }
           
            DispatchQueue.main.async(execute: { () -> Void in
                if let imgData = imageData,let fetchedImage =  UIImage(data: imgData){
                    
                    if self.imageUrl == urlString{
                        self.stopLoadingView()
                        self.image = fetchedImage
                    }
                    
                    cashedImages[urlString] = fetchedImage
                    
                    if let cell = self.superview as? CellforGroupMemberAndFriends{ //Patch
                        if let  vc = cell.referenceOfCollectionView{
                            vc.reloadData()
                        }
                    }
                }
            })
            
        }).resume()
    }
    
    let loadingIndicator:UIActivityIndicatorView={
        let loading = UIActivityIndicatorView()
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.activityIndicatorViewStyle = .gray
        loading.backgroundColor = UIColor.init(white: 0.5, alpha: 0)
        loading.layer.cornerRadius = 8
        loading.layer.masksToBounds = true
        return loading
    }()
    
    
    public func startLoadingView(){
       
        if !self.subviews.contains(loadingIndicator){
            self.addSubview(loadingIndicator)
            loadingIndicator.startAnimating()
            
            loadingIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
            loadingIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
            loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
    }
    public func stopLoadingView(){
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.removeFromSuperview()
    }
    
}


extension UIView{
     func setBorder(status:Int){
        
        
        self.layer.borderWidth = 3
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 17
        
        switch status {
        case 0:
            self.layer.borderColor = UIColor.white.cgColor
        case 1:
            self.layer.borderColor = UIColor.green.cgColor
        default:
            self.layer.borderColor = UIColor.getYellowishColor().cgColor
        }
    }
}

