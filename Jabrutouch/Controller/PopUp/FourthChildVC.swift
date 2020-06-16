//
//  FourthVC.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 16/06/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class FourthChildVC: UIViewController {

    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var popupSubTitle: UILabel!
    
    var currentPopup: JTPopup?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      popupTitle.text = currentPopup?.title
      popupSubTitle.text = currentPopup?.subTitle
    }


}
