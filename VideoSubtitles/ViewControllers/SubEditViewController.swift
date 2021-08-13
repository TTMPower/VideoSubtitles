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
    
    @IBOutlet weak var colorSubtitles: UIView!
    @IBAction func updateSubtitles(_ sender: Any) {
        dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
