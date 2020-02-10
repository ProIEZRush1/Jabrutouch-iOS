//
//  PaymentViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 05/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var creditCardView: UIView!
    @IBOutlet weak var creditCardButton: UIButton!
    
    @IBOutlet weak var applePayView: UIView!
    @IBOutlet weak var applePayButton: UIButton!
    
    @IBOutlet weak var payPalView: UIView!
    @IBOutlet weak var payPalButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setBorders()
        self.roundCornors()
        self.setShadow()
        // Do any additional setup after loading the view.
    }
    
    func setBorders() {
        self.creditCardView.layer.borderColor = Colors.borderGray.cgColor
        self.creditCardView.layer.borderWidth = 1.0
        
        self.applePayView.layer.borderColor = Colors.borderGray.cgColor
        self.applePayView.layer.borderWidth = 1.0
        
        self.payPalView.layer.borderColor = Colors.borderGray.cgColor
        self.payPalView.layer.borderWidth = 1.0
        
    }
    
    func roundCornors() {
        self.creditCardView.layer.cornerRadius = self.creditCardView.bounds.height/2
        self.creditCardView.layer.cornerRadius = self.creditCardView.bounds.height/2
        
        self.applePayView.layer.cornerRadius = self.applePayView.bounds.height/2
        self.applePayView.layer.cornerRadius = self.applePayView.bounds.height/2
        self.applePayButton.layer.cornerRadius = self.applePayView.bounds.height/2
        
        self.payPalView.layer.cornerRadius = self.payPalView.bounds.height/2
        self.payPalView.layer.cornerRadius = self.payPalView.bounds.height/2
        
    }
    
    func setShadow() {
        let color = #colorLiteral(red: 0.157, green: 0.166, blue: 0.393, alpha: 0.2)
        Utils.dropViewShadow(view: self.creditCardView, shadowColor: color, shadowRadius: 12, shadowOffset: CGSize(width: 0, height: 12))
        Utils.dropViewShadow(view: self.applePayView, shadowColor: color, shadowRadius: 12, shadowOffset: CGSize(width: 0, height: 12))
        Utils.dropViewShadow(view: self.payPalView, shadowColor: color, shadowRadius: 12, shadowOffset: CGSize(width: 0, height: 12))
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func creditCardButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func applePayButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func payPalButtonPressed(_ sender: Any) {
        
    }
    
}
