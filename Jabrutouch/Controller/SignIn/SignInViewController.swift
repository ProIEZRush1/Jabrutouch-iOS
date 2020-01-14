//בעזרת ה׳ החונן לאדם דעת
//  SignInViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 17/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import MessageUI

class SignInViewController: UIViewController, MFMailComposeViewControllerDelegate {

    //============================================================
    // MARK: - Properties
    //============================================================
    
    private var activityView: ActivityView?
    
    //============================================================
    // MARK: - Outlets
    //============================================================
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var usernameView: UIView!
    @IBOutlet weak private var passwordView: UIView!
    @IBOutlet weak private var usernameTF: UITextField!
    @IBOutlet weak private var passwordTF: UITextField!
    @IBOutlet weak private var signInButton: UIButton!
    @IBOutlet weak private var signUpButton: UIButton!
    @IBOutlet weak private var forgotPasswordButton: UIButton!
    
    //============================================================
    // MARK: - LifeCycle
    //============================================================
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStrings()
        self.addBorders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
        self.roundCorners()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //============================================================
    // MARK: - Setup
    //============================================================
    
    private func setStrings() {
        self.titleLabel.text = Strings.signIn
        self.usernameTF.placeholder = Strings.emailOrPhoneNumber
        self.passwordTF.placeholder = Strings.password
        self.signInButton.setTitle(Strings.signInCaps, for: .normal)
        self.forgotPasswordButton.setTitle(Strings.forgotPassword, for: .normal)
        
        let signUpTitle = NSMutableAttributedString(string: Strings.dontHaveAccount, attributes: [NSAttributedString.Key.foregroundColor: Colors.textMediumBlue])
        let range = (Strings.dontHaveAccount as NSString).range(of: Strings.signUp)
//        signUpTitle.addAttributes([NSAttributedString.Key.underlineStyle:NSNumber(value: 1)], range: range)
        signUpTitle.addAttributes([NSAttributedString.Key.font: Fonts.boldFont(size:18)], range: range)
        self.signUpButton.setAttributedTitle(signUpTitle, for: .normal)
    }

    private func roundCorners() {
        self.signInButton.layer.cornerRadius = self.signInButton.bounds.height/2
        self.usernameTF.layer.cornerRadius = self.usernameTF.bounds.height/2
        self.passwordTF.layer.cornerRadius = self.passwordTF.bounds.height/2
        self.usernameView.layer.cornerRadius = self.usernameView.bounds.height/2
        self.passwordView.layer.cornerRadius = self.passwordView.bounds.height/2
        self.signUpButton.layer.cornerRadius = self.signUpButton.bounds.height/2
    }
    
    private func addBorders() {
        self.usernameView.layer.borderColor = Colors.borderGray.cgColor
        self.usernameView.layer.borderWidth = 1.0
        
        self.passwordView.layer.borderColor = Colors.borderGray.cgColor
        self.passwordView.layer.borderWidth = 1.0
        
        self.signUpButton.layer.borderColor = Colors.appBlue.cgColor
        self.signUpButton.layer.borderWidth = 2.0
//        self.usernameTF.layer.borderColor = Colors.borderGray.cgColor
//        self.usernameTF.layer.borderWidth = 1.0
        
//        self.passwordTF.layer.borderColor = Colors.borderGray.cgColor
//        self.passwordTF.layer.borderWidth = 1.0
    }
    
    //============================================================
    // MARK: - email controller
    //============================================================
    func sendEmail() {
        
        if( MFMailComposeViewController.canSendMail() ) {
            let mailComposer = MFMailComposeViewController()
            let toRecipend = "app@dafyomi.es"
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients([toRecipend])
//          mailComposer.setSubject("Refund request for voucher: \(voucherItem.voucherId)")
//          mailComposer.setMessageBody("Message from: \(fullName)\n Phone number: \(phoneNumber ?? "") \n\n Hello support,\n\n ", isHTML: false)
            self.present(mailComposer, animated: true, completion: nil)
        }
        else {
            let message = "Please set an email account"
            let title = "No mail account found"
            Utils.showAlertMessage(message, title: title, viewControler: self)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
      controller.dismiss(animated: true)
    }
    
    //============================================================
    // MARK: - @IBActions
    //============================================================
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        self.signInButton.backgroundColor = #colorLiteral(red: 0.18, green: 0.17, blue: 0.66, alpha: 1)
        self.validateForm()
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        self.navigateToForgotPassword()
    }
    
    //============================================================
    // MARK: - SignIn
    //============================================================
    
    private func validateForm() {
        self.showActivityView()
        var phoneNumber: String?
        var email: String?
        guard let username = self.usernameTF.text else {
            let message = Strings.usernameMissing
            let title = Strings.missingField
            Utils.showAlertMessage(message, title: title, viewControler: self) { (acton) in
                self.signInButton.backgroundColor = #colorLiteral(red: 1, green: 0.37, blue: 0.31, alpha: 1)
            }
            self.removeActivityView()
            return
        }
        guard username.isEmpty == false else {
            let message = Strings.usernameMissing
            let title = Strings.missingField
            Utils.showAlertMessage(message, title: title, viewControler: self) { (acton) in
                self.signInButton.backgroundColor = #colorLiteral(red: 1, green: 0.37, blue: 0.31, alpha: 1)
            }
            self.removeActivityView()
            return
        }
        
        guard let password = self.passwordTF.text else {
            let message = Strings.passwordMissing
            let title = Strings.missingField
            Utils.showAlertMessage(message, title: title, viewControler: self) { (acton) in
                self.signInButton.backgroundColor = #colorLiteral(red: 1, green: 0.37, blue: 0.31, alpha: 1)
            }
            self.removeActivityView()
            return
        }
        guard password.isEmpty == false else {
            let message = Strings.passwordMissing
            let title = Strings.missingField
            Utils.showAlertMessage(message, title: title, viewControler: self) { (acton) in
                self.signInButton.backgroundColor = #colorLiteral(red: 1, green: 0.37, blue: 0.31, alpha: 1)
            }
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
            let title = Strings.invalidField
            Utils.showAlertMessage(message, title: title, viewControler: self) { (acton) in
                self.signInButton.backgroundColor = #colorLiteral(red: 1, green: 0.37, blue: 0.31, alpha: 1)
            }
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
                MessagesRepository.shared.getMessages()
            case .failure(let error):
                let message = error.message
                Utils.showAlertMessage(message,title:"",viewControler:self)
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
    
    func navigateToSignUp() {
        self.performSegue(withIdentifier: "toSignUp", sender: self)
    }
    
    private func navigateToForgotPassword() {
        self.performSegue(withIdentifier: "toForgotPassword", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toForgotPassword" {
            let forgotPasswordVC = segue.destination as? ForgotPasswordViewController
            forgotPasswordVC?.signInViewController = self
        }
    }
    
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.usernameTF {
            self.passwordTF.becomeFirstResponder()
        }
        else if textField === self.passwordTF {
            textField.resignFirstResponder()
            self.validateForm()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            if textField === self.usernameTF {
                textField.placeholder = "Email or phone number"
            } else if textField == self.passwordTF {
                textField.placeholder = "Password"
            }
        }
    }
}
