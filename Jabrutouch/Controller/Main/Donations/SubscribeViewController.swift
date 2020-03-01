//
//  ThirdChildViewController.swift
//  Jabrutouch
//
//  Created by AviDeutsch on 26/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class SubscribeViewController: UIViewController {

    @IBOutlet weak var ketarimLabel: UILabel!
    var ketarim = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ketarimLabel.text = "\(ketarim) out of 50 Ketarim"
        // Do any additional setup after loading the view.
    }
    


}
