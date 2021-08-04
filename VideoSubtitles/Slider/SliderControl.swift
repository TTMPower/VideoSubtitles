//
//  SliderControl.swift
//  VideoSubtitles
//
//  Created by Владислав Вишняков on 04.08.2021.
//

import UIKit

class SliderControl: UIControl {
    
    private var previousLocation = CGPoint()
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    var minimumValue: CGFloat  =  0
    var maximumValue: CGFloat  =  1
    var lowerValue: CGFloat  =  0.2
    var upperValue: CGFloat  =  0.8
    
    var thumbImage = UIImage(named: "slider8")
    private let thumbImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        thumbImageView.image = thumbImage
        addSubview(thumbImageView)
        
    }
    required init?(coder: NSCoder) {
        fatalError("fatal error")
    }
    // 1
    private func updateLayerFrames() {
        thumbImageView.frame = CGRect(origin: thumbOriginForValue(lowerValue),
                                      size: thumbImage!.size)
        
    }
    // 2
    func positionForValue(_ value: CGFloat) -> CGFloat {
        return bounds.width * value
    }
    // 3
    private func thumbOriginForValue(_ value: CGFloat) -> CGPoint {
        let x = positionForValue(value) - thumbImage!.size.width / 2.0
        return CGPoint(x: x, y: (bounds.height - thumbImage!.size.height) + 15)
    }
    
}

extension SliderControl {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        if thumbImageView.frame.contains(previousLocation) {
            thumbImageView.isHighlighted = true
        }
        sendActions(for: .valueChanged)
        return thumbImageView.isHighlighted
    }
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        let deltaLocation = location.x - previousLocation.x
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / bounds.width
        
        previousLocation = location
        
        if thumbImageView.isHighlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateLayerFrames()
        CATransaction.commit()
        return true
    }
    
    private func boundValue(_ value: CGFloat, toLowerValue lowerValue: CGFloat,
                            upperValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), maximumValue)
    }
    
}
