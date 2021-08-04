//
//  MySlider.swift
//  VideoSubtitles
//
//  Created by Владислав Вишняков on 04.08.2021.
//

import UIKit

class MySlider: UIViewController {
    
    let slider = SliderControl(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.backgroundColor = .lightGray
        view.addSubview(slider)
        
    }
    
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 40
        let weidht = view.bounds.width - 2 * margin
        let height: CGFloat = 70
        slider.frame = CGRect(x: 0, y: 0, width: weidht, height: height)
        slider.center = view.center
        slider.layer.cornerRadius = 5
    }

}
