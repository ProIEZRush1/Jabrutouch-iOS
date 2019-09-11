//בעזרת ה׳ החונן לאדם דעת
//  GemaraNavigationController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class GemaraNavigationController: UINavigationController {

    weak var modalDelegate: MainModalDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let gemaraViewController = self.children.first as? GemaraViewController {
            gemaraViewController.delegate = self.modalDelegate
        }
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
