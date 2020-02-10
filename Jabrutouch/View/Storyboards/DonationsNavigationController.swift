//
//  DonationsNavigationController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 23/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class DonationsNavigationController: UINavigationController {

    weak var modalDelegate: MainModalDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let donationViewController = self.children.first as? DonationsViewController {
            donationViewController.delegate = self.modalDelegate
        }
    }
    

}
