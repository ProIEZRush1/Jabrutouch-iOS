//
//  DonateViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 28/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class DonateViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var amountToPayTF: UITextField!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var slider: CustomTrackHeightSlider!
    @IBOutlet weak var subscriptionButton: UIButton!
    @IBOutlet weak var monthlyLabel: UILabel!
    @IBOutlet weak var singelPaymentButton: UIButton!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var donationValueLabel: UILabel!
    @IBOutlet weak var descriptionTitleLabel: UILabel!
    @IBOutlet weak var descreptionLabel: UILabel!
    @IBOutlet weak var keterView: UIView!
    @IBOutlet weak var numberOfKtarimLabel: UILabel!
    @IBOutlet weak var cancelSubscriptionLabel: UILabel!
    @IBOutlet weak var continueView: UIView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var continueLabel: UILabel!
    @IBOutlet weak var amountToDonateLabel: UILabel!
    
    var isSingelPayment: Bool = false
    var isSubscription: Bool = true
    
    var donation: JTDonation?
    var crowns: [JTCrown] = []
    var dedication: [JTDedication] = []
    var numberOfCrownsSinget = 5
    var numberOfCrownsSubsciption = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.donationValueLabel.isHidden = true
        self.cancelSubscriptionLabel.isHidden = true
        self.amountToPayTF.delegate = self
        self.setBorders()
        self.setRoundCorners()
        self.setSlider()
        self.getDonationDatd()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.setButtonsColorAndFont()
        self.setState()
    }
    
    private func setRoundCorners() {
        self.shadowView.layer.cornerRadius = 10
        self.shadowView.clipsToBounds = true
        self.amountToPayTF.layer.cornerRadius = 10
        self.amountToPayTF.clipsToBounds = true
        self.continueButton.layer.cornerRadius = 18
        self.continueButton.clipsToBounds = true
        self.continueView.layer.cornerRadius = 18
        self.continueView.clipsToBounds = true
    }
    
    func setBorders() {
        self.shadowView.layer.borderColor = Colors.borderGray.cgColor
        self.shadowView.layer.borderWidth = 1.0
    }
    
    func setSlider() {
        self.slider.value = 0
        
    }
    
    func setState() {
        self.setButtonsColorAndFont()
        guard let amountToDonate = self.amountToPayTF.text else { return }
        guard let amount = Int(amountToDonate) else { return }
        var numberOfKetarim = self.numberOfCrownsSubsciption
        if self.isSingelPayment {
            numberOfKetarim = amount / self.numberOfCrownsSinget
            self.monthlyLabel.text = "One Time Donation"
            self.donationValueLabel.isHidden = true
            self.cancelSubscriptionLabel.isHidden = true
        } else {
            numberOfKetarim = amount / self.numberOfCrownsSubsciption
            self.monthlyLabel.text = "Monthly"
            self.donationValueLabel.isHidden = false
            self.cancelSubscriptionLabel.isHidden = false

        }
        self.descreptionLabel.text = "Your donation eligeble for \(numberOfKetarim) lessons each month"
        self.numberOfKtarimLabel.text = "\(numberOfKetarim)"
        self.amountToDonateLabel.text = "\(amountToDonate)"
    }
    
    fileprivate func setButtonsColorAndFont() {
        singelPaymentButton.backgroundColor = isSingelPayment ? .white : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        subscriptionButton.backgroundColor = isSubscription ? .white : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        
        
        singelPaymentButton.titleLabel?.font = isSingelPayment ? UIFont(name: "SFProDisplay-Heavy", size: 18) : UIFont(name: "SFProDisplay-Medium", size: 18)
        subscriptionButton.titleLabel?.font = isSubscription ? UIFont(name: "SFProDisplay-Heavy", size: 18) : UIFont(name: "SFProDisplay-Medium", size: 18)
        
        singelPaymentButton.setTitleColor(isSingelPayment ? UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 1) : UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 0.55), for: .normal)
        subscriptionButton.setTitleColor(isSubscription ? UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 1) : UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 0.55), for: .normal)
        
    }
    
    func getDonationDatd() {
        DonationManager.shared.getDonationData( completion: { result in
            switch result {
            case .success(let donation):
                self.donation = donation
                self.dedication = donation.dedication
                self.crowns = donation.crowns
                for crown in self.crowns {
                    if crown.paymentType == "singel" {
                        self.numberOfCrownsSinget = crown.dollarPerCrown
                    }
                    if crown.paymentType == "Subscription" {
                        self.numberOfCrownsSubsciption = crown.dollarPerCrown
                    }
                }
            case .failure(_):
                break
            }
        })
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
        performSegue(withIdentifier: "unwindToMain", sender: self)
    }
    
    
    @IBAction func singelPaymentButtonPressed(_ sender: Any) {
        self.amountToPayTF.text = "54"
        self.slider.value = 54 / 200
        self.isSingelPayment = true
        self.isSubscription = false
        self.setState()
    }
    
    @IBAction func subscriptionButtonPressed(_ sender: Any) {
        self.amountToPayTF.text = "18"
        self.slider.value = 0
        self.isSingelPayment = false
        self.isSubscription = true
        self.setState()
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "presentDedication", sender: self)
    }
    
    @IBAction func slider(_ sender: UISlider) {
        if self.isSingelPayment{
            
            let value = sender.value * 2000
            sender.minimumValue = 0
            sender.maximumValue = 1
            var displayValue = Int(value)
            if Int(value) < 18 {
                displayValue = 18
            }
            amountToPayTF.text = String(displayValue)
        } else {
            let value = sender.value * 200
            sender.minimumValue = 0
            sender.maximumValue = 1
            var displayValue = Int(value)
            if Int(value) < 18 {
                displayValue = 18
            }
            amountToPayTF.text = String(displayValue)
        }
        self.setState()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.setState()
        if let text = textField.text {
            if let value = Int(text) {
                var displayValue: Float = 0.0
                if self.isSingelPayment {
                    displayValue = Float(value) / Float(2000.0)
                } else {
                    displayValue = Float(value) / Float(200.0)
                }
                if value <= 18 {
                    self.slider.value = 0
                } else {
                    self.slider.value = displayValue
                }
            }
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       self.view.endEditing(true)
        self.setState()
        if let text = self.amountToPayTF.text {
            if let value = Int(text) {
                var displayValue: Float = 0.0
                if self.isSingelPayment {
                    displayValue = Float(value) / Float(2000.0)
                } else {
                    displayValue = Float(value) / Float(200.0)
                }
                if value <= 18 {
                    self.slider.value = 0
                } else {
                    self.slider.value = displayValue
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentDedication" {
            let dedicationVC = segue.destination as? DedicationViewController
            if let amountToPay = Int(self.amountToDonateLabel.text ?? "0") {
                dedicationVC?.amountToPay = amountToPay
            }
            dedicationVC?.isSubscription = self.isSubscription
            dedicationVC?.dedication = self.dedication
        }
    }
}
