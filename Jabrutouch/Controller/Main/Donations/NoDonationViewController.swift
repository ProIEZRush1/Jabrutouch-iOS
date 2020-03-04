//
//  firstChildViewController.swift
//  Jabrutouch
//
//  Created by AviDeutsch on 24/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class NoDonationViewController: UIViewController {
    
    @IBOutlet var donateLables: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        donateLables[0].text = "YOUR DONATION"
        donateLables[1].text = "0 Ketarim remaining of your donation"
//        donateLables[2].text = "Our community lives and thrives on the support of it’s members. "
        donateLables[3].text = "Donate more and continue your support."
        
    }
    
    
    
    
}
