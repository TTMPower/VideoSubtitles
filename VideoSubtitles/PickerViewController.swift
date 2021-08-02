//
//  PickerViewController.swift
//  VideoSubtitles
//
//  Created by Владислав Вишняков on 02.08.2021.
//

import UIKit
import AVFoundation

class PickerViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    let picker = UIImagePickerController()
    
    @IBAction func pickerVideo(_ sender: Any) {
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        picker.mediaTypes = ["public.movie"]
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    // MARK: Делегат отмены выбора видео
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        print("Видео не выбрано")
    }
    
    // MARK: Делегат выброна метода
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            dismiss(animated: true, completion: nil)
            guard let movieUrl = info[.mediaURL] as? URL else {
                return
            }
        // Работа с видео
            print(movieUrl)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
    }
}
