// בעזרת ה׳ החונן לאדם דעת
//  SignUpViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 17/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    //============================================================
    // MARK: - Outlets
    //============================================================
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var firstNameTF: UITextField!
    @IBOutlet weak private var lastNameTF: UITextField!
    @IBOutlet weak private var emailTF: UITextField!
    @IBOutlet weak private var passwordTF: UITextField!
    @IBOutlet weak private var signUpButton: UIButton!
    @IBOutlet weak private var signInButton: UIButton!
    //============================================================
    // MARK: - LifeCycle
    //============================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStrings()
        self.roundCorners()
        self.addBorders()
    }
    
    //============================================================
    // MARK: - Setup
    //============================================================
    
    private func setStrings() {
        self.titleLabel.text = Strings.signUpPC
        self.firstNameTF.placeholder = Strings.firstName
        self.lastNameTF.placeholder = Strings.surname
        self.emailTF.placeholder = Strings.emailAddress
        self.passwordTF.placeholder = Strings.password
        self.signUpButton.setTitle(Strings.signUpPC, for: .normal)
        
        let signInButtonTitle = NSMutableAttributedString(string: Strings.alreadyHaveAnAccountSignIn, attributes: [NSAttributedString.Key.foregroundColor: Colors.textMediumBlue])
        let range = (Strings.alreadyHaveAnAccountSignIn as NSString).range(of: Strings.signIn)
        signInButtonTitle.addAttributes(
            [NSAttributedString.Key.underlineStyle:NSNumber(value: 1)],
            range: range)
        self.signInButton.setAttributedTitle(signInButtonTitle, for: .normal)
    }
    
    private func roundCorners() {
        self.signUpButton.layer.cornerRadius = self.signUpButton.bounds.height/2
        self.firstNameTF.layer.cornerRadius = self.firstNameTF.bounds.height/2
        self.lastNameTF.layer.cornerRadius = self.lastNameTF.bounds.height/2
        self.emailTF.layer.cornerRadius = self.emailTF.bounds.height/2
        self.passwordTF.layer.cornerRadius = self.passwordTF.bounds.height/2
    }
    
    private func addBorders() {
        self.firstNameTF.layer.borderColor = Colors.borderGray.cgColor
        self.firstNameTF.layer.borderWidth = 1.0
        
        self.lastNameTF.layer.borderColor = Colors.borderGray.cgColor
        self.lastNameTF.layer.borderWidth = 1.0
        
        self.emailTF.layer.borderColor = Colors.borderGray.cgColor
        self.emailTF.layer.borderWidth = 1.0
        
        self.passwordTF.layer.borderColor = Colors.borderGray.cgColor
        self.passwordTF.layer.borderWidth = 1.0
    }
    //============================================================
    // MARK: - @IBActions
    //============================================================
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
