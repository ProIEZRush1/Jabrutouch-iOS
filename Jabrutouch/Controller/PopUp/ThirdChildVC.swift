//
//  ThirdVCViewController.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 16/06/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class ThirdChildVC: UIViewController {

    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var popupSubTitle: UILabel!
    
    var currentPopup: JTPopup?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupTitle.text = currentPopup?.title
        popupSubTitle.text = currentPopup?.subTitle
    }
    func setup(){
        popupTitle.textColor =  UIColor(red: 0.174, green: 0.17, blue: 0.338, alpha: 0.88)
    }
    
}
