//
//  SecondChildViewController.swift
//  Jabrutouch
//
//  Created by AviDeutsch on 25/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class SingleDonationViewController: UIViewController {

    @IBOutlet var donateLabels: [UILabel]!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var hearts: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        donateLabels[0].text = "YOUR DONATION"
        donateLabels[1].text = "\(15) out of 50 ketarim"
        donateLabels[2].text =  "left to use by students"
       
    }
    

}
