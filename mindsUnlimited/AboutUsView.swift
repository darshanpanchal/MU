//
//  AboutUsView.swift
//  mindsUnlimited
//
//  Created by IPS on 02/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit
import FacebookShare

class AboutUsView: GeneralViewController,MenuItemDelegate {
    
    let likePageId = "1865472293720419"
    let appstorURL = "https://itunes.apple.com/in/app/minds-unlimited/id1110506727?mt=8"
    let linkedInId = "10345964"
    
    var termCndtionsButton:UIButton={
        let btn = UIButton()
        btn.addTarget(InAppManager.self, action: #selector(InAppManager.showTermConditions), for: .touchUpInside)
        btn.setTitleColor(UIColor.getThemeTextColor(), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.setTitle(Vocabulary.getWordFromKey(key: "inapp.popup.term_condition"), for: .normal)
        return btn
    }()
    
    var descriptionLabel:VerticalAlignedLabel={
        let label = VerticalAlignedLabel()
        label.font = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 20 : 17)
        label.textColor = UIColor.getThemeTextColor()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    let socialMediaContainerView = MenuItemsCollection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.labelTitleOnNavigation.text = Vocabulary.getWordFromKey(key: "title.about_us").uppercased()
        self.backButtonOnNavigationView.isHidden = false
        
        let attributedString = NSMutableAttributedString(string:Vocabulary.getWordFromKey(key: "about_us_desciption"))
        
        if attributedString.setAsLink(textToFind: "info@mindsunlimited.se", linkURL: "info@mindsunlimited.se"){
            descriptionLabel.attributedText = attributedString
        }else{
            
            if String.getSelectedLanguage() == "1"{
                descriptionLabel.text = "This app is developed by Minds Unlimited and Mindfulnessgruppen - which aim to help people and organizations to develop inner leadership with the help of the research-based knowledge that is within mindfulness and emotional intelligence. \n\nMinds Unlimited specializes in training managers and employees. Mindfulnessgruppen focuses on training and certifying mindfulness instructors but also provides courses for individuals. \n\nFor more information about us visit mindsunlimited.se and mindfulnessgruppen.se. If you have questions or comments please contact us at: info@mindsunlimited.se."
            }else{
                descriptionLabel.text = "Den här appen är utvecklad av Minds Unlimited och Mindfulnessgruppen - två utbildningsföretag som hjälper människor och organisationer at utvecklas med hjälp av den forskningsbaserade kunskap som finns inom mindfulness och emotionell intelligens. \n\nMinds Unlimited specialiserar sig på utbildningar för ledare och medarbetare inom företag och organisationer.\n\nMindfulnessgruppen arbetar främst med utbildning och diplomering av mindfulnessinstruktörer men har även utbildningar och fördjupningskurser för privatpersoner. \n\nMer information om oss finns på mindsunlimited.se och mindfulnessgruppen.se. Har du frågor eller synpunkter är du välkommen att kontakta oss på info@mindsunlimited.se."
            }
        }
        
        self.backgroudImageView.backgroundColor = .white
        self.backgroudImageView.addSubview(socialMediaContainerView)
        self.backgroudImageView.addSubview(termCndtionsButton)
        socialMediaContainerView.typeOfMenu = .social
        self.backgroudImageView.addSubview(descriptionLabel)
        self.backgroudImageView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: descriptionLabel)
        self.backgroudImageView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: termCndtionsButton)
        self.backgroudImageView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: socialMediaContainerView)
        
        descriptionLabel.topAnchor.constraint(equalTo: self.customNavigationImageView.bottomAnchor, constant: 5).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: socialMediaContainerView.topAnchor, constant: 0).isActive = true
        socialMediaContainerView.heightAnchor.constraint(equalToConstant: DeviceType.isIpad() ? 120 : 90).isActive = true
        
        socialMediaContainerView.bottomAnchor.constraint(equalTo: self.termCndtionsButton.topAnchor, constant: -5).isActive = true
        
        self.termCndtionsButton.bottomAnchor.constraint(equalTo: self.backgroudImageView.bottomAnchor, constant: -5).isActive = true
        
        let fbLogo = DataSourceForMenuCollection()
        fbLogo.imageName = "facebook_logo"
        fbLogo.uniqueId = "share"
        fbLogo.titleForCell = Vocabulary.getWordFromKey(key: "about_us.share").capitalized
        
        let fbLogo1 = DataSourceForMenuCollection()
        fbLogo1.imageName = "facebook_logo"
        fbLogo1.uniqueId = "like"
        fbLogo1.titleForCell = Vocabulary.getWordFromKey(key: "about_us.like").capitalized
        
        let linkedIn = DataSourceForMenuCollection()
        linkedIn.imageName = "linkedin_logo"
        linkedIn.uniqueId = "linkedIn"
        linkedIn.titleForCell = Vocabulary.getWordFromKey(key: "about_us.label.follow").capitalized
        
        socialMediaContainerView.menuDataSource = [fbLogo,fbLogo1,linkedIn]
        socialMediaContainerView.delegate = self
        
        
    }
    
    override func backButtonActionHandeler(){
        self.popToHomeView()
    }
 
    func didSelectItemAtIndexPath(selectedCellInfo: DataSourceForMenuCollection) {
      
        let application = UIApplication.shared
        
        if selectedCellInfo.uniqueId == "share",let shareURL = URL(string: appstorURL){
                      
//                      urlString = "https://apps.apple.com/us/app/werkules/id1488572477"//"https://apps.apple.com/ng/app/werkules/id1488572477?ign-mpt=uo%3D2"
                      
                      let items = [shareURL]
                      let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                      activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                      
                      // present the view controller
                      self.present(activityViewController, animated: true, completion: nil)
           /*
            GoogleAnalytics.setEvent(id: "fb_shar", title: "Facebook Share Button")
            let content = LinkShareContent(url: shareURL, title: "Minds Unlimited", description: nil, quote: nil, imageURL: nil)
            let shareDialog = ShareDialog(content: content)
            shareDialog.mode = .automatic
            shareDialog.failsOnInvalidData = true
            shareDialog.completion = { result in
                // Handle share results
            }
            do{
                try shareDialog.show()
            }catch{
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
            }
             */
        }else if selectedCellInfo.uniqueId == "like"{
        
            GoogleAnalytics.setEvent(id: "fb_like", title: "Facebook Like Button")
        
            guard let fbPageURLForApp = URL(string:"fb://profile/\(likePageId)") else {
                return
            }
            
            if !application.openURL(fbPageURLForApp){
               
                guard let fbPageURL = URL(string:"http://www.facebook.com/\(likePageId)") else {
                    return
                }
                if !application.openURL(fbPageURL){
                    
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
                }
           
            }
            
        }else if selectedCellInfo.uniqueId == "linkedIn"{
            
            GoogleAnalytics.setEvent(id: "linkedIn", title: "Linked In Button")
            
            guard let linkedInUrl = URL(string:"linkedin://company?id=\(linkedInId)") else {
                return
            }
            if !application.openURL(linkedInUrl){
                
                guard let linkedIdBrowserId = URL(string:"http://www.linkedin.com/company/\(linkedInId)") else {
                    return
                }
                
                if !application.openURL(linkedIdBrowserId){
                     ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
                }
               
            }
        }
    }

}
