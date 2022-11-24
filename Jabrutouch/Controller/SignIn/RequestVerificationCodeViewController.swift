//בעזרת ה׳ החונן לאדם דעת
//  RequestVerificationCodeViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 17/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class RequestVerificationCodeViewController: UIViewController {
    
    //============================================================
    // MARK: - Properties
    //============================================================
    
    private var activityView: ActivityView?
    
    private var countriesPicker: UIPickerView?
    private var currentCountry = LocalizationManager.shared.getDefaultCountry() {
        didSet {
            self.countryTF.text = self.currentCountry?.fullDisplayName
        }
    }
    //============================================================
    // MARK: - Outlets
    //============================================================
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var countryLabel: UILabel!
    @IBOutlet weak private var phoneNumberLabel: UILabel!
    @IBOutlet weak private var countryTF: UITextField!
    @IBOutlet weak private var phoneNumberTF: UITextField!
    @IBOutlet weak private var sendButton: UIButton!
    @IBOutlet weak private var countryView: UIView!
    @IBOutlet weak private var phoneNumberView: UIView!
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
        
        self.setStrings()
        self.roundCorners()
        self.addBorders()
        self.initCountriesPicker()
        self.setInputViews()
        self.checkOTPRequestorStatus()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //============================================================
    // MARK: - Setup
    //============================================================
    
    private func setStrings() {
        self.titleLabel.text = Strings.verification
        self.subtitleLabel.text = Strings.weWillSendOTP
        self.countryLabel.text = Strings.country.uppercased()
        self.countryTF.text = self.currentCountry?.fullDisplayName
        self.phoneNumberLabel.text = Strings.phoneNumber.uppercased()
        self.sendButton.setTitle(Strings.send, for: .normal)
    }
    
    private func roundCorners() {
        self.sendButton.layer.cornerRadius = self.sendButton.bounds.height/2
        self.countryTF.layer.cornerRadius = self.countryTF.bounds.height/2
        self.phoneNumberTF.layer.cornerRadius = self.phoneNumberTF.bounds.height/2
        self.countryView.layer.cornerRadius = self.countryView.bounds.height/2
        self.phoneNumberView.layer.cornerRadius = self.phoneNumberView.bounds.height/2
    }
    
    private func addBorders() {
        self.countryView.layer.borderColor = Colors.borderGray.cgColor
        self.countryView.layer.borderWidth = 1.0

        self.phoneNumberView.layer.borderColor = Colors.borderGray.cgColor
        self.phoneNumberView.layer.borderWidth = 1.0
//        self.countryTF.layer.borderColor = Colors.borderGray.cgColor
//        self.countryTF.layer.borderWidth = 1.0
//
//        self.phoneNumberTF.layer.borderColor = Colors.borderGray.cgColor
//        self.phoneNumberTF.layer.borderWidth = 1.0
    }
    
    private func initCountriesPicker() {
        self.countriesPicker = UIPickerView()
        self.countriesPicker?.backgroundColor = Colors.offwhiteLight
        self.countriesPicker?.dataSource = self
        self.countriesPicker?.delegate = self
    }
    
    private func setInputViews() {
        if let pickerView = self.countriesPicker {
            self.countryTF.inputView = pickerView
            
            let accessoryView = Utils.keyboardToolBarWithDoneAndCancelButtons(tintColor: Colors.appBlue, target: self, doneSelector: #selector(self.keyboardDonePressed(_:)), cancelSelector: #selector(self.keyboardCancelPressed(_:)))
            self.countryTF.inputAccessoryView = accessoryView
        }
    }
    
    //============================================================
    // MARK: - @IBActions
    //============================================================
    
    @objc func keyboardDonePressed(_ sender: Any) {
        if let index = self.countriesPicker?.selectedRow(inComponent: 0) {
            self.currentCountry = LocalizationManager.shared.getCountries()[index]
        }
        self.view.endEditing(true)
    }
    
    @objc func keyboardCancelPressed(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        self.validateForm()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //============================================================
    // MARK: - Logic
    //============================================================
    
    private func validateForm() {
        self.showActivityView()
        
        guard var phoneNumber = self.phoneNumberTF.text else {
            let message = Strings.phoneNumberMissing
            let title = Strings.missingField
            Utils.showAlertMessage(message, title: title, viewControler: self)
            self.removeActivityView()
            return
        }
        if phoneNumber.isEmpty {
            let message = Strings.phoneNumberMissing
            let title = Strings.missingField
            Utils.showAlertMessage(message, title: title, viewControler: self)
            self.removeActivityView()
            return
        }
        
        if Utils.validatePhoneNumber(phoneNumber) == false {
            let message = Strings.phoneNumberInvalid
            let title = Strings.invalidField
            Utils.showAlertMessage(message, title: title, viewControler: self)
            self.removeActivityView()
            return
        }
        
        if phoneNumber.first == "0"{
            phoneNumber = String(phoneNumber.dropFirst())
        }
        
        guard let country = self.currentCountry else {
            let message = Strings.pleaseSelectCountry
            Utils.showAlertMessage(message, title: nil, viewControler: self)
            self.removeActivityView()
            return
        }
        
        let fullPhoneNumber = country.dialCode + phoneNumber
        self.requestCode(phoneNumber: fullPhoneNumber)
    }
    
    private func requestCode(phoneNumber: String) {
        LoginManager.shared.requestVerificationCode(phoneNumber: phoneNumber) { (result) in
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
                    self.navigateToVerificatonCodeViewController(phoneNumber: phoneNumber)
                }
            case .failure(let error):
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
        case  .open:
            //all good continue
            break
        }
    }
    
    private func suspendedScreen() {
        self.otpStatusMessageLabel.text = Strings.contactAdmin
        self.toggleEnableFields(enable: false)
    }
    
    private func toggleEnableFields(enable: Bool) {
        self.countryTF.isEnabled = enable
        self.phoneNumberTF.isEnabled = enable
        self.sendButton.isEnabled = enable
        self.sendButton.backgroundColor = enable ? #colorLiteral(red: 1, green: 0.4658099413, blue: 0.384850353, alpha: 1) : .gray
        self.sendButton.isEnabled = enable
        self.otpStatusMessageLabel.isHidden = enable
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
    
    private func setOtpMessage(otpStatus: JTOTPRequestorStatus){
            let releaseTime = Date(timeIntervalSince1970:otpStatus.nextRequestAllowedTime)
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                let now = Date()
                let difference = Calendar.current.dateComponents([.second, .minute, .hour], from: now, to: releaseTime)
                let timeString = "\(difference.hour!):\(difference.minute!):\(difference.second!)"
                self.otpStatusMessageLabel.text = Strings.tryAgainIn + timeString
                
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
    
    private func navigateToVerificatonCodeViewController(phoneNumber:String) {
        self.performSegue(withIdentifier: "showVerificationCode", sender: phoneNumber)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVerificationCode" {
            let validateCodeVC = segue.destination as? ValidateVerificationCodeViewController
            validateCodeVC?.phoneNumber = sender as? String
        }
    }
}

extension RequestVerificationCodeViewController: UIPickerViewDelegate {
    
}

extension RequestVerificationCodeViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return LocalizationManager.shared.getCountries().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let country = LocalizationManager.shared.getCountries()[row]
        
        return country.fullDisplayName
    }
    
}

extension RequestVerificationCodeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === self.countryTF {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.phoneNumberTF {
            textField.resignFirstResponder()
            self.validateForm()
        }
        return true
    }
}
