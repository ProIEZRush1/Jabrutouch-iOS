//
//  ChangeSettingsViewController.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 08/03/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class ChangeSettingsViewController: UIViewController {
    
    var userDonation : JTUserDonation?
    //    ========================================
    //     MARK: - @IBOutlets
    //    ========================================
    
    @IBOutlet weak var paymentMethodButton: UIButton!
    @IBOutlet weak var subscriptionButton: UIButton!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var subscriptionLabel: UILabel!
    
    //    ========================================
    //     MARK: - 
    //    ========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setText()
    }
    
   
    //    ========================================
    //     MARK: - setup
    //    ========================================
    func setText() {
        guard let userDonation = self.userDonation else { return }
        self.paymentMethodButton.setTitle("---", for: .normal)
        self.subscriptionButton.setTitle("$\(userDonation.donatePerMonth) \(Strings.monthly)", for: .normal)
        self.subscriptionLabel.text = Strings.subscription
        self.paymentMethodLabel.text = Strings.paymentMethod
    }
    
    //    ========================================
    //     MARK: - @IBActions
    //    ========================================
    
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
