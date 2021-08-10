//
//  additions.swift
//  VideoSubtitles
//
//  Created by Владислав Вишняков on 10.08.2021.
//

import Foundation
import AVFoundation
import UIKit

class Additions {
    static var share = Additions()
    
    var minuteTimeOut = Int()
    var secondTimeOut = Int()
    
    func playOrpayse(player: AVPlayer, button: UIButton, timer: Void) {
        if !player.isPlaying {
            button.setImage(UIImage(named: "pause"), for: .normal)
            player.play()
            timer
            
        } else {
            button.setImage(UIImage(named: "play-button"), for: .normal)
            player.pause()
            timer
        }
    }
    
    func onlyPause(player: AVPlayer, button: UIButton) {
            button.setImage(UIImage(named: "play-button"), for: .normal)
            player.pause()
    }
    
    func formattedTime(minute: Int, second: Int) -> String {
        let formattedMinute = minute / 60
        let formattedSecond = second % 60
        
        secondTimeOut = formattedSecond
        minuteTimeOut = formattedMinute
        
        return String(format: "%02i:%02i", formattedMinute, formattedSecond)
    }
}
