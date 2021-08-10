//
//  SubEditViewController.swift
//  VideoSubtitles
//
//  Created by Владислав Вишняков on 09.08.2021.
//

import UIKit

class SubEditViewController: UIViewController {

  
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBOutlet weak var textViewSubtitles: UITextView!
    @IBOutlet weak var colorSubtitles: UIView!
    @IBAction func updateSubtitles(_ sender: Any) {
        dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
