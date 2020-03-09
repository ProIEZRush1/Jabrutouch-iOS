//
//  ChangeSettingsViewController.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 08/03/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class ChangeSettingsViewController: UIViewController {

    @IBOutlet weak var progress: UIView!
    @IBOutlet var progressAnimation: UIView!
    @IBOutlet weak var progressAnimationTraiing: NSLayoutConstraint!
//    ========================================
//     MARK: - @IBOutlets
//    ========================================

    override func viewDidLoad() {
        super.viewDidLoad()

     
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func paymentMethodPressed(_ sender: Any) {
//        performSegue(withIdentifier: "presentSetings", sender: self)
    }

    @IBAction func subscriptionPressed(_ sender: Any) {
//        performSegue(withIdentifier: "presentSetings", sender: self)
    }
    

}
