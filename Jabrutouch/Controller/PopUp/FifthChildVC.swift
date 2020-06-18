//
//  FifthVC.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 16/06/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class FifthChildVC: UIViewController {

    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var popupSubTitle: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageIndicator: UIActivityIndicatorView!
    
    var currentPopup: JTPopup?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.imageIndicator.startAnimating()
        popupTitle.text = currentPopup?.title
        popupSubTitle.text = currentPopup?.subTitle
        guard let imageString = currentPopup?.image else { return }
        guard let imageUrl = URL(string: imageString)  else { return }
        image.load(url: imageUrl)
    }
    
    
    
//    ==============
//    MARK: - setup
//    ==============
    func setup(){
        image.layer.cornerRadius = 15
        image.layer.masksToBounds = true
    }

}
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
