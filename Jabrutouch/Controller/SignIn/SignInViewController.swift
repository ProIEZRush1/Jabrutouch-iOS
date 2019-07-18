//בעזרת ה׳ החונן לאדם דעת
//  SignInViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 17/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    //============================================================
    // MARK: - Outlets
    //============================================================
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var usernameTF: UITextField!
    @IBOutlet weak private var passwordTF: UITextField!
    @IBOutlet weak private var signInButton: UIButton!
    @IBOutlet weak private var signUpButton: UIButton!
    @IBOutlet weak private var forgotPasswordButton: UIButton!
    
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
        self.titleLabel.text = Strings.signIn
        self.usernameTF.placeholder = Strings.emailOrPhoneNumber
        self.passwordTF.placeholder = Strings.password
        self.signInButton.setTitle(Strings.signIn, for: .normal)
        self.forgotPasswordButton.setTitle(Strings.forgotPassword, for: .normal)
        
        let signUpTitle = NSMutableAttributedString(string: Strings.dontHaveAccount, attributes: [NSAttributedString.Key.foregroundColor: Colors.textMediumBlue])
        let range = (Strings.dontHaveAccount as NSString).range(of: Strings.signUp)
        signUpTitle.addAttributes([NSAttributedString.Key.underlineStyle:NSNumber(value: 1)], range: range)
        self.signUpButton.setAttributedTitle(signUpTitle, for: .normal)
    }

    private func roundCorners() {
        self.signInButton.layer.cornerRadius = self.signInButton.bounds.height/2
        self.usernameTF.layer.cornerRadius = self.usernameTF.bounds.height/2
        self.passwordTF.layer.cornerRadius = self.passwordTF.bounds.height/2
    }
    
    private func addBorders() {
        self.usernameTF.layer.borderColor = Colors.borderGray.cgColor
        self.usernameTF.layer.borderWidth = 1.0
        
        self.passwordTF.layer.borderColor = Colors.borderGray.cgColor
        self.passwordTF.layer.borderWidth = 1.0
    }
    //============================================================
    // MARK: - @IBActions
    //============================================================
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "presentMain", sender: nil)
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        
    }
}
