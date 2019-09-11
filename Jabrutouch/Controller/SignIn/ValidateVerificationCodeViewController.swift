//בעזרת ה׳ החונן לאדם דעת
//  ValidateVerificationCodeViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 17/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class ValidateVerificationCodeViewController: UIViewController {
    
    //============================================================
    // MARK: - Properties
    //============================================================
    
    private var activityView: ActivityView?
    var phoneNumber: String?
    var code = ""
    let codeLength = 4
    //============================================================
    // MARK: - Outlets
    //============================================================
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var phoneNumberLabel: UILabel!
    @IBOutlet weak private var codeTF: TextFieldWithDeleteDelegate!
    @IBOutlet weak private var backButton: UIButton!
    @IBOutlet weak private var resendButton: UIButton!
    
    //============================================================
    // MARK: - LifeCycle
    //============================================================
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStrings()
        self.setupCodeTextField()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //============================================================
    // MARK: - Setup
    //============================================================
    
    private func setStrings() {
        self.titleLabel.text = Strings.verificationCode
        self.subtitleLabel.text = Strings.enterTheVerificationCodeSentTo
        self.phoneNumberLabel.text = self.phoneNumber
        let resendButtonTitle = NSMutableAttributedString(string: Strings.resendCode, attributes: [NSAttributedString.Key.foregroundColor: Colors.textMediumBlue])
        let range = (Strings.resendCode as NSString).range(of: Strings.sendAgain)
        resendButtonTitle.addAttributes(
            [NSAttributedString.Key.underlineStyle:NSNumber(value: 1)],
            range: range)
        self.resendButton.setAttributedTitle(resendButtonTitle, for: .normal)
        
        self.codeTF.text = "••••"
    }
    
    
    private func setupCodeTextField(){
        self.codeTF.deleteDelegate = self
        self.codeTF.becomeFirstResponder()
        self.codeTF.defaultTextAttributes.updateValue(20, forKey: .kern)
    }
    //============================================================
    // MARK: - @IBAction
    //============================================================
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resendCodeButtonPressed(_ sender: UIButton) {
        self.code = ""
        self.codeTF.text = self.displayCode(fromCode: "")
        self.resendCode()
    }
    
    //============================================================
    // MARK: - Private Methods
    //============================================================

    private func displayCode(fromCode code: String) -> String{
        var displayCode = ""
        for i in 0..<self.codeLength {
            if self.code.count > i {
                displayCode += "\(self.code[i])"
            }
            else {
                displayCode += "•"
            }
        }
        return displayCode
    }
    
    private func resendCode() {
        guard let phoneNumber = self.phoneNumber else { return }
        self.showActivityView()
        LoginManager.shared.resendCode(phoneNumber: phoneNumber) { (result) in
            self.removeActivityView()
            switch result {
            case .success:
                break
            case .failure(let error):
                let title = Strings.error
                let message = error.localizedDescription
                Utils.showAlertMessage(message, title: title, viewControler: self)
            }
        }
    }
    
    private func validateCode() {
        guard let phoneNumber = self.phoneNumber else { return }
        self.showActivityView()
        LoginManager.shared.validateCode(phoneNumber: phoneNumber, code: self.code) { (result) in
            switch result {
            case .success(let userId):
                self.navigateToSignUp(phoneNumber: phoneNumber, userId: userId)
            case .failure(let error):
                self.removeActivityView()
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
    
    private func navigateToSignUp(phoneNumber: String, userId: Int) {
        self.performSegue(withIdentifier: "showSignUp", sender: (phoneNumber,userId) )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSignUp" {
            let signUpVC = segue.destination as? SignUpViewController
            signUpVC?.phoneNumber = (sender as? (String,Int))?.0
            signUpVC?.userId = (sender as? (String,Int))?.1
        }
    }
}

extension ValidateVerificationCodeViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let beginningOfDocument = textField.beginningOfDocument
        textField.selectedTextRange = textField.textRange(from: beginningOfDocument, to: beginningOfDocument)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            self.code = (self.code as NSString).replacingCharacters(in: range, with: "")
        }
        else {
            self.code = (self.code as NSString).replacingCharacters(in: range, with: string)
        }
        
        textField.text = self.displayCode(fromCode: self.code)
        if self.code.count == self.codeLength {
            textField.resignFirstResponder()
            self.validateCode()
        }
        else {
            let beginningOfDocument = textField.beginningOfDocument
            let offset = string == "" ? range.location : range.location + 1
            if let position = textField.position(from: beginningOfDocument, offset: offset) {
                textField.selectedTextRange = textField.textRange(from: position, to: position)
            }
        }
        return false
    }
}

extension ValidateVerificationCodeViewController: TextFieldDeleteDelegate {
    func textFieldDidDelete(textField: UITextField) {

    }
}
