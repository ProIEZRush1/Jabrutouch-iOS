//
//  SixthChildVC.swift
//  Jabrutouch
//
//  Image-only popup with 4:5 aspect ratio (1080x1350)
//

import UIKit

class SixthChildVC: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageIndicator: UIActivityIndicatorView!

    var currentPopup: JTPopup?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.imageIndicator.startAnimating()
        guard let imageString = currentPopup?.image else { return }
        guard let imageUrl = URL(string: imageString) else { return }
        image.load(url: imageUrl)
    }

    // ==============
    // MARK: - setup
    // ==============
    func setup() {
        image.layer.cornerRadius = 15
        image.layer.masksToBounds = true
    }
}
