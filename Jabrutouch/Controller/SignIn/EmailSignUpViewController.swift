//
//  EmailSignUpViewController.swift
//  Jabrutouch
//
//  Created by Claude Code on 2025.
//  Copyright © 2025 Ravtech. All rights reserved.
//

import UIKit

class EmailSignUpViewController: UIViewController {

    //============================================================
    // MARK: - Properties
    //============================================================

    private var activityView: ActivityView?
    var email: String?
    // userId not needed for email registration - server creates user during signup

    private var countriesPicker: UIPickerView?
    private var currentCountry = LocalizationManager.shared.getDefaultCountry() {
        didSet {
            self.countryTF?.text = self.currentCountry?.fullDisplayName
        }
    }

    //============================================================
    // MARK: - Outlets
    //============================================================

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var firstNameTF: UITextField!
    @IBOutlet weak private var lastNameTF: UITextField!
    @IBOutlet weak private var countryTF: UITextField!
    @IBOutlet weak private var phoneNumberTF: UITextField!
    @IBOutlet weak private var passwordTF: UITextField!
    @IBOutlet weak private var signUpButton: UIButton!
    @IBOutlet weak private var signInButton: UIButton!

    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var countryView: UIView!
    @IBOutlet weak var phoneNumberView: UIView!

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
        self.addBorders()
        self.initCountriesPicker()
        self.setInputViews()
        self.countryTF?.text = self.currentCountry?.fullDisplayName
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
        self.titleLabel.text = Strings.signUpPC
        self.firstNameTF.placeholder = Strings.firstName
        self.lastNameTF.placeholder = Strings.surname
        self.phoneNumberTF?.placeholder = Strings.phoneNumber
        self.passwordTF.placeholder = Strings.password
        self.signUpButton.setTitle(Strings.signUpPC, for: .normal)

        let signInButtonTitle = NSMutableAttributedString(string: Strings.alreadyHaveAnAccountSignIn, attributes: [NSAttributedString.Key.foregroundColor: Colors.textMediumBlue])
        let range = (Strings.alreadyHaveAnAccountSignIn as NSString).range(of: Strings.signInPC)
        signInButtonTitle.addAttributes([NSAttributedString.Key.font: Fonts.boldFont(size: 18)], range: range)
        self.signInButton.setAttributedTitle(signInButtonTitle, for: .normal)
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

    @objc func keyboardDonePressed(_ sender: Any) {
        if let index = self.countriesPicker?.selectedRow(inComponent: 0) {
            self.currentCountry = LocalizationManager.shared.getCountries()[index]
        }
        self.view.endEditing(true)
    }

    @objc func keyboardCancelPressed(_ sender: Any) {
        self.view.endEditing(true)
    }

    private func roundCorners() {
        self.signUpButton.layer.cornerRadius = self.signUpButton.bounds.height/2
        self.firstNameTF.layer.cornerRadius = self.firstNameTF.bounds.height/2
        self.lastNameTF.layer.cornerRadius = self.lastNameTF.bounds.height/2
        self.passwordTF.layer.cornerRadius = self.passwordTF.bounds.height/2

        self.passwordView.layer.cornerRadius = self.passwordView.bounds.height/2
        self.lastNameView.layer.cornerRadius = self.lastNameView.bounds.height/2
        self.firstNameView.layer.cornerRadius = self.firstNameView.bounds.height/2

        self.signInButton.layer.cornerRadius = self.signUpButton.bounds.height/2

        // Round phone input views
        self.countryView.layer.cornerRadius = self.countryView.bounds.height/2
        self.countryTF.layer.cornerRadius = self.countryTF.bounds.height/2
        self.phoneNumberView.layer.cornerRadius = self.phoneNumberView.bounds.height/2
        self.phoneNumberTF.layer.cornerRadius = self.phoneNumberTF.bounds.height/2
    }

    private func addBorders() {
        self.firstNameView.layer.borderColor = Colors.borderGray.cgColor
        self.firstNameView.layer.borderWidth = 1.0

        self.lastNameView.layer.borderColor = Colors.borderGray.cgColor
        self.lastNameView.layer.borderWidth = 1.0

        self.passwordView.layer.borderColor = Colors.borderGray.cgColor
        self.passwordView.layer.borderWidth = 1.0

        self.signInButton.layer.borderColor = Colors.appBlue.cgColor
        self.signInButton.layer.borderWidth = 2.0

        self.countryView.layer.borderColor = Colors.borderGray.cgColor
        self.countryView.layer.borderWidth = 1.0

        self.phoneNumberView.layer.borderColor = Colors.borderGray.cgColor
        self.phoneNumberView.layer.borderWidth = 1.0
    }

    //============================================================
    // MARK: - @IBActions
    //============================================================

    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
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
            let title = Strings.missingField
            Utils.showAlertMessage(message, title: title, viewControler: self)
            self.removeActivityView()
            return
        }
        if firstName.isEmpty {
            let message = Strings.firstNameMissing
            let title = Strings.missingField
            Utils.showAlertMessage(message, title: title, viewControler: self)
            self.removeActivityView()
            return
        }

        guard let lastName = self.lastNameTF.text else {
            let message = Strings.lastNameMissing
            let title = Strings.missingField
            Utils.showAlertMessage(message, title: title, viewControler: self)
            self.removeActivityView()
            return
        }

        if lastName.isEmpty {
            let message = Strings.lastNameMissing
            let title = Strings.missingField
            Utils.showAlertMessage(message, title: title, viewControler: self)
            self.removeActivityView()
            return
        }

        guard let password = self.passwordTF.text else {
            let message = Strings.passwordMissing
            let title = Strings.missingField
            Utils.showAlertMessage(message, title: title, viewControler: self)
            self.removeActivityView()
            return
        }

        if password.isEmpty {
            let message = Strings.passwordMissing
            let title = Strings.missingField
            Utils.showAlertMessage(message, title: title, viewControler: self)
            self.removeActivityView()
            return
        }

        guard let email = self.email else {
            self.removeActivityView()
            return
        }

        guard let phoneNumber = self.phoneNumberTF?.text, !phoneNumber.isEmpty else {
            let message = Strings.phoneNumberMissing
            let title = Strings.missingField
            Utils.showAlertMessage(message, title: title, viewControler: self)
            self.removeActivityView()
            return
        }

        guard let country = self.currentCountry else {
            self.removeActivityView()
            return
        }

        // Format phone number with country dial code
        var cleanPhone = phoneNumber
        if cleanPhone.hasPrefix("0") {
            cleanPhone = String(cleanPhone.dropFirst())
        }
        let fullPhoneNumber = "\(country.dialCode)\(cleanPhone)"

        self.attemptSignUp(firstName: firstName, lastName: lastName, email: email, phoneNumber: fullPhoneNumber, password: password)
    }

    private func attemptSignUp(firstName: String, lastName: String, email: String, phoneNumber: String, password: String) {
        LoginManager.shared.emailSignUp(firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, password: password) { (result) in
            self.removeActivityView()
            switch result {
            case .success:
                self.navigateToWelcomeTour()
                MessagesRepository.shared.getMessages()
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

    private func navigateToWelcomeTour() {
        let welcomeTourViewController = Storyboards.TourWalkThrough.welcomeTourViewController
        appDelegate.setRootViewController(viewController: welcomeTourViewController, animated: true)
    }
}

extension EmailSignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.firstNameTF {
            self.lastNameTF.becomeFirstResponder()
        } else if textField === self.lastNameTF {
            self.phoneNumberTF?.becomeFirstResponder()
        } else if textField === self.passwordTF {
            textField.resignFirstResponder()
            self.validateForm()
        }
        return true
    }
}

extension EmailSignUpViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return LocalizationManager.shared.getCountries().count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return LocalizationManager.shared.getCountries()[row].fullDisplayName
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currentCountry = LocalizationManager.shared.getCountries()[row]
    }
}
