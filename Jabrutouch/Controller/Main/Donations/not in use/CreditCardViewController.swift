//
//  CreditCardViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 05/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class CreditCardViewController: UIViewController {

    var amountToPay: Int = 0
    var saveCard: Bool = false
    var isSubscription: Bool = false
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountToPayLabel: UILabel!
    
    @IBOutlet weak var subscriptionLabel: UILabel!
    @IBOutlet weak var subscriptionTitleLabel: UILabel!
    
    @IBOutlet weak var logoImage: UIImageView!
    
    @IBOutlet weak var creditCardShadowView: UIView!
    @IBOutlet weak var creditCardContainerView: UIView!
        
    @IBOutlet weak var cardHolderNameLabel: UILabel!
    @IBOutlet weak var nameTextFieldView: UIView!
    @IBOutlet weak var nameTextField: TextFieldWithPadding!
    @IBOutlet weak var missingNameStar: UILabel!
    
    @IBOutlet weak var cardHolderNumberLabel: UILabel!
    @IBOutlet weak var cardNumberTextFieldView: UIView!
    @IBOutlet weak var cardNumberTextField: TextFieldWithPadding!
    @IBOutlet weak var missingNumberStar: UILabel!
    @IBOutlet weak var missingNumberLabel: UILabel!
       
    @IBOutlet weak var expiryLabel: UILabel!
    @IBOutlet weak var monthExpiryTextFieldView: UIView!
    @IBOutlet weak var monthExpiryTextField: TextFieldWithPadding!
       
    @IBOutlet weak var yearExpiryTextFieldView: UIView!
    @IBOutlet weak var yearExpiryTextField: TextFieldWithPadding!
    @IBOutlet weak var missingExpityStar: UILabel!
    
    @IBOutlet weak var cvvLabel: UILabel!
    @IBOutlet weak var cvvTextFieldView: UIView!
    @IBOutlet weak var cvvTextField: TextFieldWithPadding!
    @IBOutlet weak var missingCVVStar: UILabel!
       
    @IBOutlet weak var saveCardView: UIView!
    @IBOutlet weak var saveCardButton: UIButton!
    @IBOutlet weak var saveCardLabel: UILabel!
    @IBOutlet weak var sendPaymentButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameTextField.delegate = self
        self.cardNumberTextField.delegate = self
        self.monthExpiryTextField.delegate = self
        self.yearExpiryTextField.delegate = self
        self.cvvTextField.delegate = self
        
        self.setShadow()
        self.setText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.amountToPayLabel.text = "\(self.amountToPay)"
    }
    
    override func viewWillLayoutSubviews() {
        self.setRoundCorners()
        self.setBorders()
    }
    
    private func setRoundCorners() {
        self.sendPaymentButton.layer.cornerRadius = 18
        self.sendPaymentButton.clipsToBounds = true
        
        self.creditCardShadowView.layer.cornerRadius = 20
        self.sendPaymentButton.clipsToBounds = true
        
        self.creditCardContainerView.layer.cornerRadius = 20
        self.creditCardContainerView.clipsToBounds = true
        
        self.nameTextFieldView.layer.cornerRadius = self.nameTextFieldView.bounds.height/2
        self.nameTextField.layer.cornerRadius = self.nameTextField.bounds.height/2
        
        self.cardNumberTextFieldView.layer.cornerRadius = self.cardNumberTextFieldView.bounds.height/2
        self.cardNumberTextField.layer.cornerRadius = self.cardNumberTextField.bounds.height/2
        
        self.monthExpiryTextFieldView.layer.cornerRadius = self.monthExpiryTextFieldView.frame.size.height / 2
        self.monthExpiryTextFieldView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        self.yearExpiryTextFieldView.layer.cornerRadius = self.yearExpiryTextFieldView.bounds.height/2
        self.yearExpiryTextFieldView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        
        self.monthExpiryTextField.layer.cornerRadius = self.monthExpiryTextFieldView.frame.size.height / 2
        self.monthExpiryTextField.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        self.yearExpiryTextField.layer.cornerRadius = self.yearExpiryTextField.bounds.height/2
        self.yearExpiryTextField.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        
        self.cvvTextFieldView.layer.cornerRadius = self.cvvTextFieldView.bounds.height/2
        self.cvvTextField.layer.cornerRadius = self.cvvTextField.bounds.height/2
        
    }
    
    func setBorders() {
        self.nameTextFieldView.layer.borderColor = Colors.borderGray.cgColor
        self.nameTextFieldView.layer.borderWidth = 1.0
        
        self.cardNumberTextFieldView.layer.borderColor = Colors.borderGray.cgColor
        self.cardNumberTextFieldView.layer.borderWidth = 1.0
        
        self.monthExpiryTextFieldView.layer.borderColor = Colors.borderGray.cgColor
        self.monthExpiryTextFieldView.layer.borderWidth = 1.0
        
        self.yearExpiryTextFieldView.layer.borderColor = Colors.borderGray.cgColor
        self.yearExpiryTextFieldView.layer.borderWidth = 1.0
        
        self.cvvTextFieldView.layer.borderColor = Colors.borderGray.cgColor
        self.cvvTextFieldView.layer.borderWidth = 1.0
        
    }
    
    func setShadow() {
        let color = #colorLiteral(red: 0.157, green: 0.166, blue: 0.393, alpha: 0.2)
        Utils.dropViewShadow(view: self.creditCardShadowView, shadowColor: color, shadowRadius: 12, shadowOffset: CGSize(width: 0, height: 12))

    }
    
    func setText() {
        if self.isSubscription {
            self.subscriptionTitleLabel.text = "You signed up for a monthly subscription"
            self.subscriptionLabel.text = "Per Month"
        } else {
            self.subscriptionTitleLabel.text = "You Pay"
            self.subscriptionLabel.isHidden = true
        }
        self.cardHolderNameLabel.text = "Cardholder Name"
        self.cardHolderNumberLabel.text = "Card Number"
        self.sendPaymentButton.setTitle("SEND PAYMENT", for: .normal)
        self.sendPaymentButton.alpha = 0.3
    }
    
    @IBAction func backButtonBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveCardButtonPreesed(_ sender: Any) {
        self.saveCard.toggle()
        if saveCard {
            self.saveCardButton.setImage(#imageLiteral(resourceName: "circelV"), for: .normal)
            self.saveCardLabel.alpha = 1
            self.saveCardLabel.textColor = Colors.appOrange
            
        } else {
            self.saveCardButton.setImage(#imageLiteral(resourceName: "anonimus"), for: .normal)
            self.saveCardLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.43)
        }
    }
    
    @IBAction func sendPaymentButtonPressed(_ sender: Any) {
        
    }
    
}

extension CreditCardViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            self.cardNumberTextField.becomeFirstResponder()
        }
        else if textField == cardNumberTextField {
            self.monthExpiryTextField.becomeFirstResponder()
        }
        else if textField == monthExpiryTextField {
            self.yearExpiryTextField.becomeFirstResponder()
        }
        else if textField == yearExpiryTextField {
            self.cvvTextField.becomeFirstResponder()
        }
        else if textField == cvvTextField {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
