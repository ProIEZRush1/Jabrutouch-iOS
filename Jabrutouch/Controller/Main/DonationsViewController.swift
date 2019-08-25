//בעזרת ה׳ החונן לאדם דעת
//  DonationsViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 18/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class DonationsViewController: UIViewController {
    
    
    var delegate: MainModalDelegate?
    
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.delegate?.dismissMainModal()
    }
}
