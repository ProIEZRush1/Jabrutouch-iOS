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
    // MARK: - Properties
    //============================================================
    
    private var activityView: ActivityView?
    var phoneNumber: String?
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
        self.validateForm()
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //============================================================
    // MARK: - Private methods
    //============================================================
    
    private func validateForm() {
        self.showActivityView()
        
        guard let firstName = self.firstNameTF.text else {
            let message = Strings.firstNameMissing
            Utils.showAlertMessage(message, title: nil, viewControler: self)
            self.removeActivityView()
            return
        }
        if firstName.isEmpty {
            let message = Strings.firstNameMissing
            Utils.showAlertMessage(message, title: nil, viewControler: self)
            self.removeActivityView()
            return
        }
        
        guard let lastName = self.lastNameTF.text else {
            let message = Strings.lastNameMissing
            Utils.showAlertMessage(message, title: nil, viewControler: self)
            self.removeActivityView()
            return
        }
        
        if lastName.isEmpty {
            let message = Strings.lastNameMissing
            Utils.showAlertMessage(message, title: nil, viewControler: self)
            self.removeActivityView()
            return
        }
        
        guard let email = self.emailTF.text else {
            let message = Strings.emailIsMissing
            Utils.showAlertMessage(message, title: nil, viewControler: self)
            self.removeActivityView()
            return
        }
        
        if email.isEmpty {
            let message = Strings.emailIsMissing
            Utils.showAlertMessage(message, title: nil, viewControler: self)
            self.removeActivityView()
            return
        }
        
        if Utils.validateEmail(email) == false {
            let message = Strings.emailInvalid
            Utils.showAlertMessage(message, title: nil, viewControler: self)
            self.removeActivityView()
            return
        }
        
        guard let password = self.passwordTF.text else {
            let message = Strings.passwordMissing
            Utils.showAlertMessage(message, title: nil, viewControler: self)
            self.removeActivityView()
            return
        }
        
        if password.isEmpty {
            let message = Strings.passwordMissing
            Utils.showAlertMessage(message, title: nil, viewControler: self)
            self.removeActivityView()
            return
        }
     
        self.attemptSignUp(firstName: firstName, lastName: lastName, phoneNumber: self.phoneNumber ?? "", email: email, password: password)
    }
    
    private func attemptSignUp(firstName: String, lastName: String, phoneNumber: String, email: String, password: String) {
        LoginManager.shared.signUp(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, email: email, password: password) { (result) in
            self.removeActivityView()
            switch result {
            case .success:
                self.navigateToMain()
            case .failure(let error):
                let title = Strings.error
                let message = error.localizedDescription
                Utils.showAlertMessage(message, title: title, viewControler: self)
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
    // MARK: - Navigation
    //============================================================
    
    private func navigateToMain() {
        let mainViewController = Storyboards.Main.mainViewController
        appDelegate.setRootViewController(viewController: mainViewController, animated: true)

    }
}
