//בס״ד
//  ProfileViewController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 07/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
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
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
