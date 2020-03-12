//בעזרת ה׳ החונן לאדם דעת
//  ValidateVerificationCodeViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 17/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import MessageUI

class ValidateVerificationCodeViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
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
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var sendEmailButton: UIButton!
    
    //============================================================
    // MARK: - LifeCycle
    //============================================================
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStrings()
        self.setSendEmailText()
        self.setupCodeTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setTimer()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //============================================================
    // MARK: - Setup
    //============================================================
    func setSendEmailText() {
        let string = "o regístrate por correo electrónico"
        let sendEmailTitle = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: Colors.textMediumBlue])
        let range = NSRange(location: 2, length: string.count - 2)
        sendEmailTitle.addAttributes([NSAttributedString.Key.underlineStyle:NSNumber(value: 1)], range: range)
        self.sendEmailButton.setAttributedTitle(sendEmailTitle, for: .normal)
        
    }
    private func setStrings() {
        self.titleLabel.text = Strings.verificationCode
        self.subtitleLabel.text = Strings.enterTheVerificationCodeSentTo
        self.phoneNumberLabel.text = self.phoneNumber
        let resendButtonTitle = NSMutableAttributedString(string: Strings.resendCode, attributes: [NSAttributedString.Key.foregroundColor: Colors.textMediumBlue])
//        let range = (Strings.resendCode as NSString).range(of: Strings.sendAgain)
        let range = NSRange(location: 25, length: 15)
        resendButtonTitle.addAttributes(
            [NSAttributedString.Key.underlineStyle:NSNumber(value: 1)],
            range: range)
        self.resendButton.setAttributedTitle(resendButtonTitle, for: .normal)
        self.timerLabel.text = "Por favor espera 30 segundos para recibir el código"
        self.codeTF.text = "••••"
        
        
    }
    
    private func setTimer() {
        self.resendButton.isHidden = true
        self.sendEmailButton.isHidden = true
        self.timerLabel.isHidden = false
        var counter = 29
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            self.timerLabel.text = "Por favor espera \(counter) segundos para recibir el código"
            counter -= 1
            if counter < 0 {
                timer.invalidate()
                self.resendButton.isHidden = false
                self.sendEmailButton.isHidden = false
                self.timerLabel.isHidden = true
            }
        }
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
        self.setTimer()
        self.code = ""
        self.codeTF.text = self.displayCode(fromCode: "")
        let resendButtonTitle = NSMutableAttributedString(string: Strings.resendCode, attributes: [NSAttributedString.Key.foregroundColor: Colors.textMediumBlue])
//        let range = (Strings.resendCode as NSString).range(of: Strings.sendAgain)
        let range = NSRange(location: 25, length: 15)
        resendButtonTitle.addAttributes(
            [NSAttributedString.Key.underlineStyle:NSNumber(value: 1), NSAttributedString.Key.foregroundColor: Colors.appOrange],
            range: range)
        self.resendButton.setAttributedTitle(resendButtonTitle, for: .normal)

        self.resendCode()
    }
    
    @IBAction func sendEmailButtonPressed(_ sender: Any) {
        if( MFMailComposeViewController.canSendMail() ) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients(["info@tashema.es"])
            mailComposer.setSubject("No he podido registrarme con el SMS.")
            mailComposer.setMessageBody("Hola\n No he podido registrarme con el SMS. \n Mi nombre es: [Escribe aquí tu nombre]\n Mi apellido es: [tu apellido]\n Y mi teléfono es: [tu teléfono móvil con prefijo]\n\n Muchas gracia ", isHTML: false)
            self.present(mailComposer, animated: true, completion: nil)
        }
        else {
            let title = "No mail account found"
            let message = "Please set an email account"
            Utils.showAlertMessage(message, title: title, viewControler: self)
        }
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
