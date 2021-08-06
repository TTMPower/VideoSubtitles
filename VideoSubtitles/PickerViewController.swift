import UIKit
import AVFoundation

class PickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let picker = UIImagePickerController()
    
    @IBOutlet weak var labelText: UILabel!
    
    @IBAction func pickerVideo(_ sender: Any) {
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
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
        transferURL(url: movieUrl)
    }
    
    // MARK: Передача полученного урл на другой экран
    
    func transferURL(url: URL) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "SecondViewController") as? EditorViewController else { return }
        secondViewController.urlVideo = url
        show(secondViewController, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
    }
}
