//
//  ValidateEmailVerificationCodeViewController.swift
//  Jabrutouch
//
//  Created by Claude Code on 2025.
//  Copyright © 2025 Ravtech. All rights reserved.
//

import UIKit

class ValidateEmailVerificationCodeViewController: UIViewController {

    //============================================================
    // MARK: - Properties
    //============================================================

    private var activityView: ActivityView?
    var email: String?
    var code = ""
    let codeLength = 6  // Email verification uses 6-digit code
    var timer: Timer?

    //============================================================
    // MARK: - Outlets
    //============================================================

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var emailLabel: UILabel!
    @IBOutlet weak private var codeTF: TextFieldWithDeleteDelegate!
    @IBOutlet weak private var backButton: UIButton!
    @IBOutlet weak private var resendButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!

    //============================================================
    // MARK: - LifeCycle
    //============================================================

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return [.portrait, .landscapeLeft, .landscapeRight]
        } else {
            return [.portrait]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStrings()
        self.setupCodeTextField()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.checkOtpStatus()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    //============================================================
    // MARK: - Setup
    //============================================================

    private func setStrings() {
        self.titleLabel.text = Strings.emailVerificationCode
        self.subtitleLabel.text = Strings.enterEmailVerificationCode
        self.emailLabel.text = self.email

        let resendButtonTitle = NSMutableAttributedString(string: Strings.resendEmailCode, attributes: [NSAttributedString.Key.foregroundColor: Colors.textMediumBlue])
        // Underline "Enviar otra vez" part
        let fullString = Strings.resendEmailCode as NSString
        if let range = findRangeOfSendAgain(in: fullString) {
            resendButtonTitle.addAttributes(
                [NSAttributedString.Key.underlineStyle: NSNumber(value: 1)],
                range: range)
        }
        self.resendButton.setAttributedTitle(resendButtonTitle, for: .normal)
        self.codeTF.text = String(repeating: "\u{2022}", count: codeLength) // 6 dots for 6-digit code
    }

    private func findRangeOfSendAgain(in string: NSString) -> NSRange? {
        // Try to find "Enviar otra vez" in the string
        let searchString = "Enviar otra vez"
        let range = string.range(of: searchString)
        if range.location != NSNotFound {
            return range
        }
        return nil
    }

    private func toggleHideSendButtonsShowTimer(hideBtnsShowTimer: Bool) {
        self.resendButton.isHidden = hideBtnsShowTimer
        self.timerLabel.isHidden = !hideBtnsShowTimer
        if !hideBtnsShowTimer { self.timerLabel.text = "" }
    }

    /// only let resend code if otp status is okay
    private func checkOtpStatus() {
        guard let currentStatus = UserDefaultsProvider.shared.otpStatus else { return }
        /// I don't think it's ever possible to get here if suspended, but check anyways.
        guard currentStatus.status != .suspended else {
            /// leave this screen
            self.dismiss(animated: true)
            return
        }

        if Date().timeIntervalSince1970 < currentStatus.nextRequestAllowedTime {
            self.toggleHideSendButtonsShowTimer(hideBtnsShowTimer: true)
            let releaseTime = Date(timeIntervalSince1970: currentStatus.nextRequestAllowedTime)

            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                let now = Date()

                /// display seconds only countdown
                let seconds = String(Int(releaseTime.timeIntervalSince1970 - now.timeIntervalSince1970))
                let text = String(format: Strings.didntReceiveCodeTryAgainIn, arguments: [seconds])
                self.timerLabel.text = text

                /// stop timer when finished
                if now.timeIntervalSince1970 > currentStatus.nextRequestAllowedTime {
                    self.timer?.invalidate()
                    self.toggleHideSendButtonsShowTimer(hideBtnsShowTimer: false)
                }
            }
        } else {
            self.toggleHideSendButtonsShowTimer(hideBtnsShowTimer: false)
        }
    }

    private func setupCodeTextField() {
        self.codeTF.deleteDelegate = self
        self.codeTF.becomeFirstResponder()
        self.codeTF.defaultTextAttributes.updateValue(15, forKey: .kern)  // Slightly smaller kerning for 6 digits
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
        let resendButtonTitle = NSMutableAttributedString(string: Strings.resendEmailCode, attributes: [NSAttributedString.Key.foregroundColor: Colors.textMediumBlue])
        let fullString = Strings.resendEmailCode as NSString
        if let range = findRangeOfSendAgain(in: fullString) {
            resendButtonTitle.addAttributes(
                [NSAttributedString.Key.underlineStyle: NSNumber(value: 1), NSAttributedString.Key.foregroundColor: Colors.appOrange],
                range: range)
        }
        self.resendButton.setAttributedTitle(resendButtonTitle, for: .normal)

        self.resendCode()
    }

    //============================================================
    // MARK: - Private Methods
    //============================================================

    private func displayCode(fromCode code: String) -> String {
        var displayCode = ""
        for i in 0..<self.codeLength {
            if self.code.count > i {
                displayCode += "\(self.code[i])"
            } else {
                displayCode += "\u{2022}"  // bullet character
            }
        }
        return displayCode
    }

    /// handle requesting a code the second time
    private func resendCode() {
        guard let email = self.email else { return }
        self.showActivityView()
        LoginManager.shared.requestEmailVerificationCode(email: email) { (result) in
            self.removeActivityView()
            switch result {
            case .success(let status):
                /// Save new received status to UserDefaults for next time user enters this screen.
                UserDefaultsProvider.shared.otpStatus = status.otpRequestorStatus

                switch status.otpRequestorStatus.status {
                case .suspended:
                    /// leave validation screen.
                    self.dismiss(animated: true)
                case .open, .wait, .hold:
                    /// show wait for email message timer.
                    self.checkOtpStatus()
                }
            case .failure(let error):
                let title = Strings.error
                let message = error.message
                Utils.showAlertMessage(message, title: title, viewControler: self)
            }
        }
    }

    private func validateCode() {
        guard let email = self.email else { return }
        self.showActivityView()
        LoginManager.shared.validateEmailCode(email: email, code: self.code) { (result) in
            switch result {
            case .success(let userId):
                self.navigateToSignUp(email: email, userId: userId)
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

    private func navigateToSignUp(email: String, userId: Int) {
        self.performSegue(withIdentifier: "showEmailSignUp", sender: (email, userId))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEmailSignUp" {
            let signUpVC = segue.destination as? EmailSignUpViewController
            signUpVC?.email = (sender as? (String, Int))?.0
            signUpVC?.userId = (sender as? (String, Int))?.1
        }
    }
}

extension ValidateEmailVerificationCodeViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let beginningOfDocument = textField.beginningOfDocument
        textField.selectedTextRange = textField.textRange(from: beginningOfDocument, to: beginningOfDocument)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            self.code = (self.code as NSString).replacingCharacters(in: range, with: "")
        } else {
            self.code = (self.code as NSString).replacingCharacters(in: range, with: string)
        }

        textField.text = self.displayCode(fromCode: self.code)
        if self.code.count == self.codeLength {
            textField.resignFirstResponder()
            self.validateCode()
        } else {
            let beginningOfDocument = textField.beginningOfDocument
            let offset = string == "" ? range.location : range.location + 1
            if let position = textField.position(from: beginningOfDocument, offset: offset) {
                textField.selectedTextRange = textField.textRange(from: position, to: position)
            }
        }
        return false
    }
}

extension ValidateEmailVerificationCodeViewController: TextFieldDeleteDelegate {
    func textFieldDidDelete(textField: UITextField) {
        // Handle delete key press
    }
}
