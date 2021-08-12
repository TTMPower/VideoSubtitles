import UIKit

class SliderControl: UIControl {

    static var share = SliderControl()
    private var previousLocation = CGPoint() {
        didSet {
            updateLayerFrames()
        }
    }
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    var minimumValue: Float = 0
    var maximumValue: Float = 1
    var lowerValue: Float = 0.02
    var currentThumbPoint = CGPoint()
    var thumbImage = UIImage(named: "slider9")
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
                                      size: CGSize(width: 15, height: 60))
        CATransaction.commit()
    }
    
    func positionForValue(_ value: Float) -> Float {
        return Float(bounds.width) * value
    }
    
    private func thumbOriginForValue(_ value: Float) -> CGPoint {
        let x = positionForValue(value) - Float(thumbImage!.size.width) / 2
        let y = (bounds.height - thumbImage!.size.height) / 2
        return  CGPoint (x: CGFloat(x), y: y )
    }
}

extension SliderControl {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        if thumbImageView.frame.contains(previousLocation) {
            thumbImageView.isHighlighted = true
        }
        return thumbImageView.isHighlighted
    }
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let currentPoint = location
        currentThumbPoint = currentPoint
        let percentage = currentPoint.x / bounds.width;
        let delta = Float(percentage) * (maximumValue - minimumValue)
        if thumbImageView.isHighlighted {
            let value = minimumValue + delta
            lowerValue = boundValue(value, toLowerValue: minimumValue, toMaxValue: maximumValue)
        }
        sendActions(for: .valueChanged)
        return true
    }
    
    private func boundValue(_ value: Float, toLowerValue lowerValue: Float, toMaxValue: Float) -> Float {
        return min(max(value, lowerValue), toMaxValue)
    }
    
}
