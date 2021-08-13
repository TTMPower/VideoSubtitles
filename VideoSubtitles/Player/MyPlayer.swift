//
//  MyPlayer.swift
//  VideoSubtitles
//
//  Created by Владислав Вишняков on 10.08.2021.
//

import Foundation
import AVFoundation
import UIKit

/*
 FIXME: Здесь хотелось бы перейти от временного деления по секундам к милисекундам для более плавного UX. Ниже описал предложения.
 */

class MyPlayer {
    
    static var share = MyPlayer()
    
    var slider = SliderControl(frame: .zero)
    
    var getAdditions = Additions.share
    
    var currentTimeSeconds = Int()
    var values = Double()
    var urlVideo: URL?
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var mediaDurationOut = Int()
    var timeObserver: Any?
    var outputValue = Double()
    var sliderFrame = CGRect()
    
    
    func setupVideoPlayer(label: UILabel, playerOut: UIView,urlVideo: URL) {
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
    }
    
    func updateSliderTime(timeLine: UILabel, subOutlet: UILabel) {
        slider.updateLayerFrames()
        let interval = CMTime(seconds: 1, preferredTimescale: 2)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] time in
            self?.updateVideoPlayerSlider(time: time, subOutlet: subOutlet, timeLine: timeLine)
        })
    }
    
    func updateVideoPlayerSlider(time: CMTime, subOutlet: UILabel, timeLine: UILabel) {
        slider.updateLayerFrames()
        guard let currentTime = player?.currentTime() else { return }
        //FIXME: Попробуй вместо CMTimeGetSeconds использовать
        //        Float(currentTime.value) / Float(currentTime.timescale)
        // это должно вернуть время в долях секунды
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        slider.lowerValue = CGFloat(currentTimeInSeconds)
        if let currentItem = player?.currentItem {
            let duration = currentItem.duration
            let durationinSeconds = CMTimeGetSeconds(duration)
            self.slider.lowerValue = CGFloat(currentTimeInSeconds / durationinSeconds)
            if (CMTIME_IS_INVALID(duration)) {
                return;
            }
            slider.lowerValue = CGFloat(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
        }
        subOutlet.text = ""
        let timeLineCurrentTime = getAdditions.formattedTime(minute: Int(currentTimeInSeconds), second: Int(currentTimeInSeconds))
        outputValue = currentTimeInSeconds
        timeLine.text = String(timeLineCurrentTime)
    }
    
    func initializeSlider1(playerViewOutlet: UIView, parentView: UIView, timeLineLabel: UILabel){
        slider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
        slider.backgroundColor = .lightGray
        playerLayer.frame = playerViewOutlet.frame
        parentView.addSubview(slider)
        slider.frame = CGRect(x: 0, y: 0, width: parentView.frame.width, height: parentView.frame.height)
        sliderFrame = slider.frame
        let slider1InitialValue:Float = Float(slider.lowerValue)
        let slider1ValueInt:Int = Int(slider1InitialValue)
        timeLineLabel.text = String(slider1ValueInt)
    }
    
    @objc func rangeSliderValueChanged(_ rangeSlider: SliderControl) {
        slider.updateLayerFrames()
        player.pause()
        guard let duration = player?.currentItem?.duration else { return }
        let value = Float64(slider.lowerValue) * CMTimeGetSeconds(duration)
        let seekTime = CMTime(value: CMTimeValue(value), timescale: CMTimeScale(1))
        player?.seek(to: seekTime )
        outputValue = value
        
    }
}
