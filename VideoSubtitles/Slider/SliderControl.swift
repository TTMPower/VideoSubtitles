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
            /* FIXME:
             использование isHighlighted для индикации начала тача не лучшая идея, так как
             данная переменная используется для управления UI (This property determines whether the regular or highlighted images are used) и следовательно будет иметь side effect. Лучшее решение будет создать переменную класса (напрмер isActionRunning) и задавать ее при начале тача, сбрасывать при отпускании тача, проверять при перемещении тача перед тем как выполнить логику.
             */
            thumbImageView.isHighlighted = true
        }
        return thumbImageView.isHighlighted
    }
    /* FIXME:
     Здесь основная проблема в перемешивании UI и бизнесс логики. Получается следующая последовательность:
        1. Из позиции thumb расчитывается value (delta + minimumValue)
        2. Value ограничевается сверху и снизу(boundValue(...))
        3. Исходя из value расчитывается положение thumb
     
     Правильнее разделить UI и бизнесс логику.
        1. Позиция thumbImageView должна задаваться исходя из позиции тача (центр тача = центр thumbImageView). Этим обеспечивается отзывачивость интерфеса.
        2. Value должно рассчитваться исходя из положения thumbImageView в контейнере. Таким образом значение слайдера точно соответствует его визуальному представлению.
        3. Когда Value задается снаружи слайдера (например AVPlayer-ом) положение должно быть рассчитано из Value.
        pseudocode: {
            let visualRange = A...B
            let valueRange = a...b
            
            var visualValue = ...
            var value = ...
            value = a + visualValue / visualRange.length * valueRange.length
            visualValue = A + value / valueRange.length * visualRange.length
        }
    */
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
        
        //FIXME: тут возможно заворачивание в транзакции не особо полезно
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateLayerFrames()
        CATransaction.commit()
        sendActions(for: .valueChanged)
        
        return true
    }
    
    private func boundValue(_ value: CGFloat, toLowerValue lowerValue: CGFloat, toMaxValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), toMaxValue)
    }
    
}
