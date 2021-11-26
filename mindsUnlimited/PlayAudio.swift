//
//  AVPlayer.swift
//  mindsUnlimited
//
//  Created by IPS on 20/02/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit
import AVFoundation
class PlayAudio:NSObject{
    
    static var player:AVAudioPlayer?
    class func playSound(localPath:String) {
        
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                
            } catch _ as NSError {
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
            }
        } catch  {
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
        }
        
        
        if let url = URL(string: localPath){
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                player.prepareToPlay()
                player.stop()
                player.play()
           
            } catch {
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "general.unknown_error_occured"))
            }
        }
    }
    
    
   
    
}

