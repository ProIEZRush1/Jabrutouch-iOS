//
//  OldDonationsViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 26/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class OldDonationsViewController: UIViewController {

    var delegate: MainModalDelegate?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.delegate?.dismissMainModal()
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
