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
    // MARK: - Properties
    //============================================================
    
    private var activityView: ActivityView?
    
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
        self.titleLabel.text = Strings.signInPC
        self.usernameTF.placeholder = Strings.emailOrPhoneNumber
        self.passwordTF.placeholder = Strings.password
        self.signInButton.setTitle(Strings.signInPC, for: .normal)
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
        self.validateFields()
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        
    }
    
    //============================================================
    // MARK: - SignIn
    //============================================================
    
    private func validateFields() {
        self.showActivityView()
        var phoneNumber: String?
        var email: String?
        guard let username = self.usernameTF.text else {
            let message = Strings.usernameMissing
            Utils.showAlertMessage(message,title:nil,viewControler:self)
            self.removeActivityView()
            return
        }
        guard username.isEmpty == false else {
            let message = Strings.usernameMissing
            Utils.showAlertMessage(message,title:nil,viewControler:self)
            self.removeActivityView()
            return
        }
        
        guard let password = self.passwordTF.text else {
            let message = Strings.passwordMissing
            Utils.showAlertMessage(message,title:nil,viewControler:self)
            self.removeActivityView()
            return
        }
        guard password.isEmpty == false else {
            let message = Strings.passwordMissing
            Utils.showAlertMessage(message,title:nil,viewControler:self)
            self.removeActivityView()
            return
        }
        
        if Utils.validateEmail(username)  {
            email = username
        }
        else if Utils.validatePhoneNumber(username) {
            phoneNumber = username
        }
        else {
            let message = Strings.usernameInvalid
            Utils.showAlertMessage(message,title:nil,viewControler:self)
            self.removeActivityView()
            return
        }
        
        self.attemptSignIn(phoneNumber: phoneNumber, email: email, password: password)
    }
    
    private func attemptSignIn(phoneNumber: String?, email: String?, password: String) {
        LoginManager.shared.signIn(phoneNumber: phoneNumber, email: email, password: password) { (result) in
            self.removeActivityView()
            switch result {
            case .success:
                self.navigateToMain()
            case .failure(let error):
                let message = error.localizedDescription
                Utils.showAlertMessage(message,title:nil,viewControler:self)
            }
        }
    }
    
    //============================================================
    // MARK: - ActivityView
    //============================================================
    
    private func showActivityView() {
        DispatchQueue.main.async {
            if self.activityView == nil {
                self.activityView = Utils.showActivityView(inView: self.view, withFrame: self.view.frame, text: nil)
            }
        }
    }
    private func removeActivityView() {
        DispatchQueue.main.async {
            if let view = self.activityView {
                Utils.removeActivityView(view)
            }
        }
    }
    //============================================================
    // MARK: - Navgation
    //============================================================
    
    private func navigateToMain() {
        let mainViewController = Storyboards.Main.mainViewController
        appDelegate.setRootViewController(viewController: mainViewController, animated: true)
    }
    
    
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.usernameTF {
            self.passwordTF.becomeFirstResponder()
        }
        else if textField === self.passwordTF {
            textField.resignFirstResponder()
            self.validateFields()
        }
        return true
    }
}
