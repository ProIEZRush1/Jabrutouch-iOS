//
//  EditPasswordCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 13/11/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class EditPasswordCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var oldContanerView: UIView!
    @IBOutlet weak var oldShadowView: UIView!
    @IBOutlet weak var newContanerView: UIView!
    @IBOutlet weak var newShadowView: UIView!
    @IBOutlet weak var confirmContanerView: UIView!
    @IBOutlet weak var confirmShadowView: UIView!
    @IBOutlet weak var changePassowrdLabel: UILabel!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var forgotFassword: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.oldPasswordTextField.delegate = self
        self.newPasswordTextField.delegate = self
        self.confirmTextField.delegate = self
        self.setText()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.roundCorners()
        self.addBorders()
        
    }
    private func roundCorners() {
        self.oldContanerView.layer.cornerRadius = self.oldContanerView.bounds.height/2
        self.oldShadowView.layer.cornerRadius = self.confirmContanerView.bounds.height/2
        self.newContanerView.layer.cornerRadius = self.newContanerView.bounds.height/2
        self.newShadowView.layer.cornerRadius = self.confirmContanerView.bounds.height/2
        self.confirmContanerView.layer.cornerRadius = self.confirmContanerView.bounds.height/2
        self.confirmShadowView.layer.cornerRadius = self.confirmContanerView.bounds.height/2
    }
    
    private func setText() {
//        self.forgotFassword.setTitle(Strings.forgotPassword, for: .normal)
        self.forgotFassword.setTitle("Forgot?", for: .normal)
        self.oldPasswordTextField.placeholder = Strings.oldPassowrd
        self.newPasswordTextField.placeholder = Strings.newPassowrd
        self.confirmTextField.placeholder = Strings.confirmPassowrd
    }
    
    private func addBorders() {
        self.oldShadowView.layer.borderColor = Colors.borderGray.cgColor
        self.oldShadowView.layer.borderWidth = 1.0
        
        self.newShadowView.layer.borderColor = Colors.borderGray.cgColor
        self.newShadowView.layer.borderWidth = 1.0
        
        self.confirmShadowView.layer.borderColor = Colors.borderGray.cgColor
        self.confirmShadowView.layer.borderWidth = 1.0
        
    }
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == oldPasswordTextField {
            self.newPasswordTextField.becomeFirstResponder()
        } else if textField == newPasswordTextField {
            self.confirmTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

}
