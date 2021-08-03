//
//  AddSubViewController.swift
//  VideoSubtitles
//
//  Created by Владислав Вишняков on 03.08.2021.
//

import UIKit

class AddSubViewController: UIViewController {
    
    var minutes:Int = 0
    var seconds:Int = 0
    
    var currentTime = String()
    var minuteTimeOut = Int()
    var secondTimeOut = Int()
    var mediaDuarion = Int()
    
    @IBOutlet weak var endTimePicker: UIPickerView!
    @IBOutlet weak var startAtOutlet: UILabel!
    @IBOutlet weak var textViewLabel: UITextView!
    @IBAction func closeWindow(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        endTimePicker.delegate = self
        startAtOutlet.text = currentTime
        print("Попытка получить секунды \(secondTimeOut)")
        print("Попытка получить минуты \(minuteTimeOut)")
    }
}

extension AddSubViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return mediaDuarion / 60
        case 1:
            return mediaDuarion % 60 + 1
            
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width/2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row) мин."
        case 1:
            return "\(row) сек."
        default:
            return ""
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            minutes = row
        case 1:
            seconds = row
        default:
            break;
        }
    }
}
