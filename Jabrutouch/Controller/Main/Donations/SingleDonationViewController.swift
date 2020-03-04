//
//  SecondChildViewController.swift
//  Jabrutouch
//
//  Created by AviDeutsch on 25/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class SingleDonationViewController: UIViewController {

    @IBOutlet var ketarimLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var hearts: UILabel!
    var unUsedCrowns = 0
    var allCrowns = 0
    var likes = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ketarimLabel.text = "\(unUsedCrowns) out of \(allCrowns) ketarim"
        hearts.text = "\(likes)"
       
    }
    

}
