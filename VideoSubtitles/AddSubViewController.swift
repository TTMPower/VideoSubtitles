//
//  AddSubViewController.swift
//  VideoSubtitles
//
//  Created by Владислав Вишняков on 03.08.2021.
//

import UIKit

class AddSubViewController: UIViewController {
    
    var currentTime = String()
    var minuteTimeOut = Int()
    var secondTimeOut = Int()
    
    @IBOutlet weak var endTimePicker: UIPickerView!
    @IBOutlet weak var startAtOutlet: UILabel!
    @IBOutlet weak var textViewLabel: UITextView!
    @IBAction func closeWindow(_ sender: Any) {
        dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        startAtOutlet.text = currentTime
        print("Попытка получить \(currentTime)")
        endTimePicker.delegate = self
    }
}

extension AddSubViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return minuteTimeOut
        case 1:
            return secondTimeOut
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width/3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row) Minute"
        case 1:
            return "\(row) Second"
        default:
            return ""
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            minuteTimeOut = row
        case 1:
            secondTimeOut = row
        default:
            break;
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(25)
    }
    
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        var pickerLabel: UILabel? = (view as? UILabel)
//        if pickerLabel == nil {
//            pickerLabel = UILabel()
//            pickerLabel?.font = UIFont(name: "System", size: 9)
//            pickerLabel?.textAlignment = .center
//        }
////        pickerLabel?.text = secondTimeOut
//        pickerLabel?.textColor = UIColor.blue
//        return pickerLabel!
//    }
    
}
