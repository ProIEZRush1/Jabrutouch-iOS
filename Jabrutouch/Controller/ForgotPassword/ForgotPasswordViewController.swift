//
//  ForgotPasswordViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 14/11/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    
    private var activityView: ActivityView?
    var emailAddress: String = ""
    var isRegisterd: Bool = false
    var signInViewController: SignInViewController?
    var userExsistsMessage: String = ""
    
    // forgot password contaner
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var containerViewTopConstrant: NSLayoutConstraint!
    
    //email sent container
    @IBOutlet weak var emailSentCcontainerView: UIView!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var secondTitleLabel: UILabel!
    @IBOutlet weak var secondSubTitleLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    // user exsist container
    @IBOutlet weak var userExistsView: UIView!
    @IBOutlet weak var sentEmailLeibel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
//    @IBOutlet weak var checkMailboxLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        
        self.setShadow()
        self.roundCornors()
        self.setBorders()
        self.setStrings()
    }
    
    func setStrings() {
        self.titleLabel.text = Strings.forgotPasswordTitle
        self.subTitleLabel.text = Strings.forgotPasswordText
        self.sendButton.setTitle(Strings.sendNow, for: .normal)
        self.secondTitleLabel.text = Strings.forgotPasswordSuccessTitle
    }
    
    func setSucssesStrings(){
        self.sentEmailLeibel.text = Strings.forgotPasswordSuccessMessage//"We sent an email to"
        self.emailAddressLabel.text = self.emailAddress
//        self.checkMailboxLabel.text = "Please check your mailbox for further instructions"
    }
    
    func roundCornors() {
        self.containerView.layer.cornerRadius = 31
        self.emailSentCcontainerView.layer.cornerRadius = 31
        self.sendButton.layer.cornerRadius = 18
        self.okButton.layer.cornerRadius = 18
        self.textFieldView.layer.cornerRadius = self.textFieldView.bounds.height/2
        self.textField.layer.cornerRadius = self.textField.bounds.height/2
        
    }
    
    func setBorders() {
        self.textFieldView.layer.borderColor = Colors.borderGray.cgColor
        self.textFieldView.layer.borderWidth = 1.0
    }
    
    func setShadow() {
        let shadowOffset = CGSize(width: 0.0, height: 20)
        let color = #colorLiteral(red: 0.16, green: 0.17, blue: 0.39, alpha: 0.5)
        Utils.dropViewShadow(view: self.containerView, shadowColor: color, shadowRadius: 31, shadowOffset: shadowOffset)
        Utils.dropViewShadow(view: self.emailSentCcontainerView, shadowColor: color, shadowRadius: 31, shadowOffset: shadowOffset)
    }
    
    
    func setSecondContainer(message: String, status: Bool) {
        self.containerView.isHidden = true
        self.emailSentCcontainerView.isHidden = false
        
        if status {
            self.isRegisterd = true
            self.userExistsView.isHidden = false
            self.secondSubTitleLabel.isHidden = true
            self.okButton.setTitle("OK", for: .normal)
            self.setSucssesStrings()
        } else {
            self.isRegisterd = false
            self.secondTitleLabel.text = ""
            self.secondSubTitleLabel.text = Strings.forgotPasswordErrorMessage
            self.okButton.setTitle(Strings.registerButtonTitle, for: .normal)
            self.userExistsView.isHidden = true
        }
        
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        if let email = self.textField.text {
            self.emailAddress = email
            self.showActivityView()
            self.forgotPassword(email)
        }
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func xButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okButtonPressed(_ sender: Any) {
        if self.isRegisterd {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: {
                DispatchQueue.main.async {
                    self.signInViewController?.navigateToSignUp()
                }
            })
        }
    }
    
    private func forgotPassword(_ email: String) {
        LoginManager.shared.forgotPassword(email: email) { (result) in
            self.removeActivityView()
            switch result {
            case .success(let result):
                self.setSecondContainer(message: result.message, status: result.status)
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
    // MARK: - TextField
    //============================================================
       
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.containerViewTopConstrant.constant = 20
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.containerViewTopConstrant.constant = 94
        if let emailAdress = textField.text {
            self.emailAddress = emailAdress
        }
        self.textField.resignFirstResponder()
        return true
    }
    
}
