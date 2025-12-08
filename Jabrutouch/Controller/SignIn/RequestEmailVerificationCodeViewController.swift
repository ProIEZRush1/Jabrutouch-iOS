//
//  RequestEmailVerificationCodeViewController.swift
//  Jabrutouch
//
//  Created by Claude Code on 2025.
//  Copyright © 2025 Ravtech. All rights reserved.
//

import UIKit
import RecaptchaEnterprise

class RequestEmailVerificationCodeViewController: UIViewController {

    //============================================================
    // MARK: - Properties
    //============================================================

    private var activityView: ActivityView?
    var recaptchaClient: RecaptchaClient?

    //============================================================
    // MARK: - Outlets
    //============================================================

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var emailLabel: UILabel!
    @IBOutlet weak private var emailTF: UITextField!
    @IBOutlet weak private var sendButton: UIButton!
    @IBOutlet weak private var emailView: UIView!
    @IBOutlet weak var otpStatusMessageLabel: UILabel!

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

        // Initialize reCAPTCHA Enterprise
        Recaptcha.fetchClient(withSiteKey: "6LdYRt0qAAAAALp2b0giTFgiHTCCBSGHWhMP5LWo") { client, error in
            guard let client = client else {
                print("Error creating RecaptchaClient: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            self.recaptchaClient = client
        }

        self.setStrings()
        self.roundCorners()
        self.addBorders()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.checkOTPRequestorStatus()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    //============================================================
    // MARK: - Setup
    //============================================================

    private func setStrings() {
        self.titleLabel.text = Strings.emailVerification
        self.subtitleLabel.text = Strings.weWillSendEmailOTP
        self.emailLabel.text = Strings.enterEmail
        self.sendButton.setTitle(Strings.send, for: .normal)
    }

    private func roundCorners() {
        self.sendButton.layer.cornerRadius = self.sendButton.bounds.height/2
        self.emailTF.layer.cornerRadius = self.emailTF.bounds.height/2
        self.emailView.layer.cornerRadius = self.emailView.bounds.height/2
    }

    private func addBorders() {
        self.emailView.layer.borderColor = Colors.borderGray.cgColor
        self.emailView.layer.borderWidth = 1.0
    }

    //============================================================
    // MARK: - @IBActions
    //============================================================

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let recaptchaClient = recaptchaClient else {
            print("Error: reCAPTCHA not initialized.")
            return
        }

        // Execute reCAPTCHA to get token
        recaptchaClient.execute(withAction: RecaptchaAction.signup) { token, error in
            guard let token = token else {
                print("Error executing reCAPTCHA: \(error?.localizedDescription ?? "Unknown")")
                Utils.showAlertMessage("No se pudo verificar el captcha", title: "Error", viewControler: self)
                return
            }

            print("reCAPTCHA Token: \(token)")

            // Validate token with backend
            RecaptchaValidator.verifyRecaptchaToken(token: token) { isValid in
                DispatchQueue.main.async {
                    if isValid {
                        self.validateForm()
                    } else {
                        Utils.showAlertMessage("Captcha fallido", title: "Error", viewControler: self)
                    }
                }
            }
        }
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    //============================================================
    // MARK: - Logic
    //============================================================

    @discardableResult
    private func validateForm() -> Bool {
        self.showActivityView()
        toggleEnableFields(enable: false)

        guard let email = self.emailTF.text else {
            let message = Strings.emailIsMissing
            let title = Strings.missingField
            Utils.showAlertMessage(message, title: title, viewControler: self)
            self.removeActivityView()
            return false
        }
        if email.isEmpty {
            let message = Strings.emailIsMissing
            let title = Strings.missingField
            Utils.showAlertMessage(message, title: title, viewControler: self)
            self.removeActivityView()
            return false
        }

        if Utils.validateEmail(email) == false {
            let message = Strings.emailInvalid
            let title = Strings.invalidField
            Utils.showAlertMessage(message, title: title, viewControler: self)
            self.removeActivityView()
            return false
        }

        self.requestCode(email: email)
        return true
    }

    private func requestCode(email: String) {
        LoginManager.shared.requestEmailVerificationCode(email: email) { (result) in
            self.removeActivityView()
            switch result {
            case .success(let status):
                // Save new received status to UserDefaults for next time user enters this screen.
                UserDefaultsProvider.shared.otpStatus = status.otpRequestorStatus

                switch status.otpRequestorStatus.status {
                case .suspended:
                    self.suspendedScreen()
                case .open, .wait, .hold:
                    self.toggleWaitStatusScreen(otpStatus: status.otpRequestorStatus)
                    self.navigateToVerificationCodeViewController(email: email)
                }
            case .failure(let error):
                self.toggleEnableFields(enable: true)
                let title = Strings.error
                let message = error.message
                Utils.showAlertMessage(message, title: title, viewControler: self)
            }
        }
    }

    //============================================================
    // MARK: - OTPRequestorStatus handling
    //============================================================

    private func checkOTPRequestorStatus() {
        guard let currentStatus = UserDefaultsProvider.shared.otpStatus else { return }

        switch currentStatus.status {
        case .suspended:
            self.suspendedScreen()
        case .hold, .wait:
            self.toggleWaitStatusScreen(otpStatus: currentStatus)
        case .open:
            // all good continue
            break
        }
    }

    private func suspendedScreen() {
        self.otpStatusMessageLabel.text = Strings.contactAdmin
        self.toggleEnableFields(enable: false)
    }

    private func toggleEnableFields(enable: Bool) {
        self.emailTF.isEnabled = enable
        self.sendButton.backgroundColor = enable ? #colorLiteral(red: 1, green: 0.4658099413, blue: 0.384850353, alpha: 1) : .gray
        self.sendButton.isEnabled = enable
        self.otpStatusMessageLabel.isHidden = enable
        if enable { otpStatusMessageLabel.text = "" }
    }

    private func toggleWaitStatusScreen(otpStatus: JTOTPRequestorStatus) {
        let date = NSDate()
        let currentUnixTime = date.timeIntervalSince1970
        let isAllowed = currentUnixTime > otpStatus.nextRequestAllowedTime
        if !isAllowed {
            self.setOtpMessage(otpStatus: otpStatus)
        }
        self.toggleEnableFields(enable: isAllowed)
    }

    private func setOtpMessage(otpStatus: JTOTPRequestorStatus) {
        let releaseTime = Date(timeIntervalSince1970: otpStatus.nextRequestAllowedTime)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            let now = Date()

            // display seconds only countdown
            let seconds = String(Int(releaseTime.timeIntervalSince1970 - now.timeIntervalSince1970))
            let text = String(format: Strings.tryAgainIn, arguments: [seconds])
            self.otpStatusMessageLabel.text = text

            // stop timer when finished
            if now.timeIntervalSince1970 > otpStatus.nextRequestAllowedTime {
                timer.invalidate()
                self.toggleEnableFields(enable: true)
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

    private func navigateToVerificationCodeViewController(email: String) {
        self.performSegue(withIdentifier: "showEmailVerificationCode", sender: email)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEmailVerificationCode" {
            let validateCodeVC = segue.destination as? ValidateEmailVerificationCodeViewController
            validateCodeVC?.email = sender as? String
        }
    }
}

extension RequestEmailVerificationCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.emailTF {
            textField.resignFirstResponder()
            self.validateForm()
        }
        return true
    }
}
