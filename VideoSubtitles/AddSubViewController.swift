//
//  AddSubViewController.swift
//  VideoSubtitles
//
//  Created by Владислав Вишняков on 03.08.2021.
//

import UIKit
import AVFoundation

protocol AddSubDelegate {
    func dataDelegate(sub: String,startTime: Int, endTime: Int, color: UIColor)
}

class AddSubViewController: UIViewController, UITextViewDelegate {
    
    var delegate: AddSubDelegate?
    
    var minutes:Int = 0
    var seconds:Int = 0
    
    @IBOutlet weak var errorOutlet: UILabel!
    var colorSubtitble = UIColor()
    var currentTime = String()
    var minuteTimeOut = Int()
    var secondTimeOut = Int()
    var mediaDuarion = Int()
    var newSubtitle = String()
    var currentTimeInSeconds = Int()
    
    @IBOutlet weak var colorSubtitles: UIView!
    @IBAction func addNewSubtitleAction(_ sender: Any) {
        newSubtitle = textViewLabel.text
        if currentTimeInSeconds  > (seconds + (minutes * 60)) {
            errorOutlet.isHidden = false
        } else {
            var endDuration = 0
            errorOutlet.isHidden = true
            dismiss(animated: true)
            endDuration = seconds + (minutes * 60)
            delegate?.dataDelegate(sub: newSubtitle,startTime: currentTimeInSeconds, endTime: endDuration, color: colorSubtitble)
            print(endDuration)
            
        }
    }
    @IBOutlet weak var endTimePicker: UIPickerView!
    @IBOutlet weak var startAtOutlet: UILabel!
    @IBOutlet weak var textViewLabel: UITextView!
    @IBAction func closeWindow(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textViewLabel.textColor == UIColor.lightGray {
            textViewLabel.text = nil
            textViewLabel.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textViewLabel.text.isEmpty {
            textViewLabel.textColor = UIColor.white
        }
    }
    
    func startView() {
        endTimePicker.delegate = self
        textViewLabel.delegate = self
        textViewLabel.text = "Введите субтитр..."
        textViewLabel.textColor = UIColor.lightGray
        startAtOutlet.text = currentTime
        colorSubtitles.backgroundColor = UIColor.clear
        colorSubtitles.backgroundColor = colorSubtitble
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startView()
    }
    
    
}

extension AddSubViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return mediaDuarion / 60 + 1
        case 1:
            return mediaDuarion % 60 + 1
        default:
            return 99
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
