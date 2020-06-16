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
    
    var currentPopup: JTPopup?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      popupTitle.text = currentPopup?.title
      popupSubTitle.text = currentPopup?.subTitle
      image.image = UIImage(named: currentPopup?.image ?? "popup")
    }

}
