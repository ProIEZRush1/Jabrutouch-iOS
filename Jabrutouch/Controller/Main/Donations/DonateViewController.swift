//
//  DonateViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 28/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class DonateViewController: UIViewController, UITextFieldDelegate, DonationDataDelegate {
   
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var amountToPayTF: UITextField!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var slider: CustomTrackHeightSlider!
    @IBOutlet weak var buttonsView: UIView!
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
    var donation: JTDonation?
    var crowns: [JTCrown] = []
    var dedication: [JTDedication] = []
    var postDedication: JTPostDedication?
    var numberOfCrownsSingel = 5
    var numberOfCrownsSubsciption = 1
    var showVideo: Bool = UserDefaultsProvider.shared.videoWatched
    var paymentType: Int = 15
    var fromDeepLink = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.donationValueLabel.isHidden = true
        self.cancelSubscriptionLabel.isHidden = true
        self.amountToPayTF.delegate = self
        self.setBorders()
        self.setRoundCorners()
        self.setSlider()
        self.getDonationData()
        self.setShadows()
        self.setText()
        self.presentVideo()
        self.fromDeepLink ? couponeCallToDedication() : self.getPushNotification()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setButtonsColorAndFont()
        self.setState()
        DonationManager.shared.donationDataDelegate = self
        
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
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
        self.buttonsView.layer.cornerRadius = self.buttonsView.bounds.height / 2
        self.subscriptionButton.layer.cornerRadius = self.subscriptionButton.bounds.height / 2
        self.singelPaymentButton.layer.cornerRadius = self.singelPaymentButton.bounds.height / 2
    }
  
    func setBorders() {
        self.shadowView.layer.borderColor = Colors.borderGray.cgColor
        self.shadowView.layer.borderWidth = 1.0
    }
    
    func setSlider() {
        self.slider.value = 0
        
    }
    
    func setText() {
        self.titleLabel.text = Strings.donations
        self.subscriptionButton.setTitle(Strings.subscription, for: .normal)
        self.singelPaymentButton.setTitle(Strings.singlePayment, for: .normal)
        self.donationValueLabel.text = Strings.x5Value
        self.donationValueLabel.text = Strings.x5Value
    }
    
    func getPushNotification(){
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else { return }
        API.getPushNotification(authToken: authToken)
    }
    
    func presentVideo() {
        if !self.showVideo {
            self.performSegue(withIdentifier: "presentVideo", sender: self)
            UserDefaultsProvider.shared.videoWatched = true
        }
    }
    
    private func setShadows() {
        let shadowOffset = CGSize(width: 0.0, height: 12)
        let color = #colorLiteral(red: 0.16, green: 0.17, blue: 0.39, alpha: 0.2)
        Utils.dropViewShadow(view: self.buttonsView, shadowColor: color, shadowRadius: 20, shadowOffset: shadowOffset)
    }
    
    func setState() {
        self.setButtonsColorAndFont()
        guard let amountToDonate = self.amountToPayTF.text else { return }
        guard let amount = Int(amountToDonate) else { return }
//        var numberOfKetarim = self.numberOfCrownsSubsciption
        guard let donation = self.donation else { return }

        var numberOfKetarim = 0
        if self.isSingelPayment {
//            numberOfKetarim = amount / self.numberOfCrownsSingel
            let donationValues = donation.crownPrice(value: amount, type: "regular")
            numberOfKetarim = donationValues.price
            self.paymentType = donationValues.id
            
            self.monthlyLabel.text = Strings.singlePayment //"One Time Donation"
            self.descriptionTitleLabel.text = Strings.singlePayment
            self.donationValueLabel.isHidden = true
            self.cancelSubscriptionLabel.isHidden = true
        } else {
//            numberOfKetarim = amount / self.numberOfCrownsSubsciption
            let donationValues = donation.crownPrice(value: amount, type: "subscription")
            numberOfKetarim = donationValues.price
            self.paymentType = donationValues.id
            self.monthlyLabel.text = Strings.monthly //"Monthly"
            self.descriptionTitleLabel.text = Strings.paidMonthly
            self.cancelSubscriptionLabel.text = Strings.cancelSubscriptionLabel
            self.donationValueLabel.isHidden = false
            self.cancelSubscriptionLabel.isHidden = false

        }
        let string = String(format: Strings.donationEligeble, "\(numberOfKetarim)")
        self.descreptionLabel.text = string
        self.numberOfKtarimLabel.text = "\(numberOfKetarim)"
        self.amountToDonateLabel.text = "\(amountToDonate)"
    }
    
    fileprivate func setButtonsColorAndFont() {
        singelPaymentButton.backgroundColor = isSingelPayment ? #colorLiteral(red: 0.1764705882, green: 0.168627451, blue: 0.662745098, alpha: 1) : .clear
        subscriptionButton.backgroundColor = !isSingelPayment ? #colorLiteral(red: 0.1764705882, green: 0.168627451, blue: 0.662745098, alpha: 1) : .clear
        
        
        singelPaymentButton.titleLabel?.font = isSingelPayment ? UIFont(name: "SFProDisplay-Heavy", size: 18) : UIFont(name: "SFProDisplay-Regular", size: 18)
        subscriptionButton.titleLabel?.font = !isSingelPayment ? UIFont(name: "SFProDisplay-Heavy", size: 18) : UIFont(name: "SFProDisplay-Regular", size: 18)
        
        singelPaymentButton.setTitleColor(isSingelPayment ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0.2359343767, green: 0.2592330873, blue: 0.7210982442, alpha: 0.48), for: .normal)
        subscriptionButton.setTitleColor(!isSingelPayment ?  #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0.2359343767, green: 0.2592330873, blue: 0.7210982442, alpha: 0.48), for: .normal)
        
    }
    func getDonationData() {
        self.donation = DonationManager.shared.donation
        self.dedication = DonationManager.shared.dedication
        self.crowns = DonationManager.shared.crowns
        for crown in self.crowns {
            if crown.paymentType == "regular" {
                self.numberOfCrownsSingel = Int(crown.dollarPerCrown)
            }
            if crown.paymentType == "subscription" {
                self.numberOfCrownsSubsciption = Int(crown.dollarPerCrown)
            }
            if crown.paymentType == "coupon" {
//            self.paymentType = crown.id
            }
        }
    }
    
    func addPostDedication(){
        
    }
    
    func setNumberView(view: HoursView) {
        view.layer.cornerRadius = 4
        view.layer.borderColor = Colors.borderGray.cgColor
        view.layer.borderWidth = 1
    }
  

    func createPostDedication() {
        var sum = 0
         if let amountToPay = Int(self.amountToDonateLabel.text ?? "0") {
             sum = amountToPay
         }

        if self.postDedication == nil {
            self.postDedication = JTPostDedication(sum: sum, paymenType: self.paymentType, nameToRepresent: "", dedicationText: "", status: "", dedicationTemplate: 0)
        } else {
            self.postDedication!.sum = sum
            self.postDedication!.paymentType = paymentType
        }
    }
    
    func donationsDataReceived() {
        self.getDonationData()
    }
    
    
    func couponeCallToDedication(){
//        self.amountToDonateLabel.text = "32"
//        self.createPostDedication()
        self.performSegue(withIdentifier: "presentDedication", sender: self)

    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
//        performSegue(withIdentifier: "unwindToMain", sender: self)
    }
    
    
    @IBAction func singelPaymentButtonPressed(_ sender: Any) {
        self.amountToPayTF.text = "54"
        self.slider.value = 54 / 2000
        self.isSingelPayment = true
        self.setState()
    }
    
    @IBAction func subscriptionButtonPressed(_ sender: Any) {
        self.amountToPayTF.text = "18"
        self.slider.value = 0
        self.isSingelPayment = false
        self.setState()
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        self.createPostDedication()
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
//            if let amountToPay = Int(self.amountToDonateLabel.text ?? "0") {
//                dedicationVC?.amountToPay = amountToPay
//            }
            dedicationVC?.dedication = self.dedication
            dedicationVC?.postDedication = self.postDedication
        }
    }
}
