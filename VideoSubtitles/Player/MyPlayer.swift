//
//  MyPlayer.swift
//  VideoSubtitles
//
//  Created by Владислав Вишняков on 10.08.2021.
//

import Foundation
import AVFoundation
import UIKit

class MyPlayer {
    
    static var share = MyPlayer()
    
    var getAdditions = Additions.share
    
    var currentTimeSeconds = Int()
    var values = Double()
    var urlVideo: URL?
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var mediaDurationOut = Int()
    var timeObserver: Any?
    
    
    func setupVideoPlayer(label: UILabel, playerOut: UIView, slider: SliderControl, subOutlet: UILabel, timeLine: UILabel, urlVideo: URL) {
        //MARK: время видео
        let asset = AVURLAsset(url: urlVideo)
        let totalSeconds = Int(CMTimeGetSeconds(asset.duration))
        let mediaDuration = getAdditions.formattedTime(minute: totalSeconds, second: totalSeconds)
        label.text = mediaDuration
        mediaDurationOut = totalSeconds
        
            player = AVPlayer(url: urlVideo)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspect
            playerOut.layer.addSublayer(playerLayer)
        let interval = CMTime(seconds: 1, preferredTimescale: 2)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] time in
            
            self?.updateVideoPlayerSlider(time: time,slider: slider, subOutlet: subOutlet, timeLine: timeLine)
        })
        
    }
    
    func updateVideoPlayerSlider(time: CMTime,slider: SliderControl, subOutlet: UILabel, timeLine: UILabel) {
        guard let currentTime = player?.currentTime() else { return }
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        slider.lowerValue = CGFloat(currentTimeInSeconds)
        if let currentItem = player?.currentItem {
            let duration = currentItem.duration
            if (CMTIME_IS_INVALID(duration)) {
                return;
            }
            let currentTime = currentItem.currentTime()
            slider.lowerValue =
                CGFloat(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
            values = currentTimeInSeconds
        }
        subOutlet.text = "" //subtitlesOutlet
        let timeLineCurrentTime = getAdditions.formattedTime(minute: Int(currentTimeInSeconds), second: Int(currentTimeInSeconds))
        currentTimeSeconds = Int(currentTimeInSeconds) + 1
        timeLine.text = String(timeLineCurrentTime) //timeLineLabel
    }
    
}
