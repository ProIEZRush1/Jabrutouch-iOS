//בעזרת ה׳ החונן לאדם דעת
//  MishnaNavigationController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class MishnaNavigationController: UINavigationController {

    weak var modalDelegate: MainModalDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mishnaViewController = self.children.first as? MishnaViewController {
            mishnaViewController.delegate = self.modalDelegate
        }
    }

}
