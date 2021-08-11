//
//  SliderControl.swift
//  VideoSubtitles
//
//  Created by Владислав Вишняков on 04.08.2021.
//

import UIKit

class SliderControl: UIControl {

    static var share = SliderControl()
    private var previousLocation = CGPoint()
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    var minimumValue: CGFloat = 0 {
        didSet {
          updateLayerFrames()
        }
      }
    var maximumValue: CGFloat = 1 {
        didSet {
          updateLayerFrames()
        }
      }
    var lowerValue: CGFloat = 0.05 {
        didSet {
          updateLayerFrames()
        }
      }
    var currentThumbPoint = CGPoint()
    var thumbImage = #imageLiteral(resourceName: "slider9") {
        didSet {
          updateLayerFrames()
        }
      }
    private let thumbImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        thumbImageView.image = thumbImage
        addSubview(thumbImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) fatal error")
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        thumbImageView.frame = CGRect(origin: thumbOriginForValue(lowerValue),
                                      size: thumbImage.size)
        CATransaction.commit()
    }
    
    func positionForValue(_ value: CGFloat) -> CGFloat {
        return bounds.width * value
    }
    
    private func thumbOriginForValue(_ value: CGFloat) -> CGPoint {
        let x = positionForValue(value) - thumbImage.size.width / 2
        let y = (bounds.height - thumbImage.size.height) / 2
        return  CGPoint (x: x, y: y )
    }
}

extension SliderControl {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        updateLayerFrames()
        previousLocation = touch.location(in: self)
        if thumbImageView.frame.contains(previousLocation) {
            thumbImageView.isHighlighted = true
        }
        return thumbImageView.isHighlighted
    }
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        updateLayerFrames()
        let location = touch.location(in: self)
        let currentPoint = location
        currentThumbPoint = currentPoint
        let percentage = currentPoint.x / bounds.width;
        let delta = CGFloat(percentage) * (maximumValue - minimumValue)
        if thumbImageView.isHighlighted {
            let value = minimumValue + delta
            lowerValue = boundValue(value, toLowerValue: minimumValue, toMaxValue: maximumValue)
        }
        sendActions(for: .valueChanged)
        
        return true
    }
    
    private func boundValue(_ value: CGFloat, toLowerValue lowerValue: CGFloat, toMaxValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), toMaxValue)
    }
    
}
