//
//  InvalidCouponeViewController.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 02/08/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class InvalidCouponeViewController: UIViewController {
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var blueButtonBox: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setText()
    }
    
    func setup(){
        alertView.layer.cornerRadius = 15
        blueButtonBox.layer.cornerRadius = 15
    }
    func setText(){
        userNameLabel.text = "Estimado \(UserDefaultsProvider.shared.currentUser?.firstName ?? ""),"
    }
    
    @IBAction func blueButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "presentDonation", sender: self)
    }
    
    @IBAction func whiteButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
