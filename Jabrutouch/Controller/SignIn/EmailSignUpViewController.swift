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
    var userId: Int?

    private var countriesPicker: UIPickerView?
    private var currentCountry = LocalizationManager.shared.getDefaultCountry() {
        didSet {
            self.countryTF?.text = self.currentCountry?.fullDisplayName
        }
    }

    // Phone input views (created programmatically)
    private var phoneContainerView: UIView!
    private var countryView: UIView!
    private var countryTF: UITextField!
    private var phoneNumberView: UIView!
    private var phoneNumberTF: UITextField!

    //============================================================
    // MARK: - Outlets
    //============================================================

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var firstNameTF: UITextField!
    @IBOutlet weak private var lastNameTF: UITextField!
    @IBOutlet weak private var emailDisplayLabel: UILabel!
    @IBOutlet weak private var passwordTF: UITextField!
    @IBOutlet weak private var signUpButton: UIButton!
    @IBOutlet weak private var signInButton: UIButton!

    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var firstNameView: UIView!

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
        self.setupPhoneInput()
        self.initCountriesPicker()
        self.setInputViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
        self.roundCorners()
        self.addPhoneBorders()
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
        // Hide email display label - we're replacing it with phone input
        self.emailDisplayLabel.isHidden = true
        self.passwordTF.placeholder = Strings.password
        self.signUpButton.setTitle(Strings.signUpPC, for: .normal)

        let signInButtonTitle = NSMutableAttributedString(string: Strings.alreadyHaveAnAccountSignIn, attributes: [NSAttributedString.Key.foregroundColor: Colors.textMediumBlue])
        let range = (Strings.alreadyHaveAnAccountSignIn as NSString).range(of: Strings.signInPC)
        signInButtonTitle.addAttributes([NSAttributedString.Key.font: Fonts.boldFont(size: 18)], range: range)
        self.signInButton.setAttributedTitle(signInButtonTitle, for: .normal)
    }

    private func setupPhoneInput() {
        // Create container view for country picker and phone number
        phoneContainerView = UIView()
        phoneContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(phoneContainerView)

        // Position the container where the email label was
        NSLayoutConstraint.activate([
            phoneContainerView.leadingAnchor.constraint(equalTo: self.lastNameTF.leadingAnchor),
            phoneContainerView.trailingAnchor.constraint(equalTo: self.lastNameTF.trailingAnchor),
            phoneContainerView.topAnchor.constraint(equalTo: self.lastNameView.bottomAnchor, constant: 15),
            phoneContainerView.heightAnchor.constraint(equalToConstant: 52)
        ])

        // Create country view (background)
        countryView = UIView()
        countryView.translatesAutoresizingMaskIntoConstraints = false
        countryView.backgroundColor = Colors.offwhiteLight
        phoneContainerView.addSubview(countryView)

        // Create country text field
        countryTF = UITextField()
        countryTF.translatesAutoresizingMaskIntoConstraints = false
        countryTF.text = self.currentCountry?.fullDisplayName
        countryTF.font = UIFont.systemFont(ofSize: 14)
        countryTF.textColor = Colors.textMediumBlue
        countryTF.backgroundColor = .white
        countryTF.textAlignment = .left
        countryTF.delegate = self
        phoneContainerView.addSubview(countryTF)

        // Create phone number view (background)
        phoneNumberView = UIView()
        phoneNumberView.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberView.backgroundColor = Colors.offwhiteLight
        phoneContainerView.addSubview(phoneNumberView)

        // Create phone number text field
        phoneNumberTF = UITextField()
        phoneNumberTF.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberTF.placeholder = Strings.phoneNumber
        phoneNumberTF.font = UIFont.systemFont(ofSize: 18)
        phoneNumberTF.textColor = Colors.textMediumBlue
        phoneNumberTF.backgroundColor = .white
        phoneNumberTF.keyboardType = .phonePad
        phoneNumberTF.delegate = self
        phoneContainerView.addSubview(phoneNumberTF)

        // Layout constraints
        NSLayoutConstraint.activate([
            // Country view (35% width)
            countryView.leadingAnchor.constraint(equalTo: phoneContainerView.leadingAnchor),
            countryView.topAnchor.constraint(equalTo: phoneContainerView.topAnchor),
            countryView.bottomAnchor.constraint(equalTo: phoneContainerView.bottomAnchor),
            countryView.widthAnchor.constraint(equalTo: phoneContainerView.widthAnchor, multiplier: 0.35),

            // Country text field inside country view
            countryTF.leadingAnchor.constraint(equalTo: countryView.leadingAnchor, constant: 2),
            countryTF.trailingAnchor.constraint(equalTo: countryView.trailingAnchor, constant: -2),
            countryTF.topAnchor.constraint(equalTo: countryView.topAnchor, constant: 5),
            countryTF.bottomAnchor.constraint(equalTo: countryView.bottomAnchor, constant: -2),

            // Phone number view (65% width minus spacing)
            phoneNumberView.trailingAnchor.constraint(equalTo: phoneContainerView.trailingAnchor),
            phoneNumberView.topAnchor.constraint(equalTo: phoneContainerView.topAnchor),
            phoneNumberView.bottomAnchor.constraint(equalTo: phoneContainerView.bottomAnchor),
            phoneNumberView.leadingAnchor.constraint(equalTo: countryView.trailingAnchor, constant: 7),

            // Phone number text field inside phone number view
            phoneNumberTF.leadingAnchor.constraint(equalTo: phoneNumberView.leadingAnchor, constant: 20),
            phoneNumberTF.trailingAnchor.constraint(equalTo: phoneNumberView.trailingAnchor, constant: -2),
            phoneNumberTF.topAnchor.constraint(equalTo: phoneNumberView.topAnchor, constant: 5),
            phoneNumberTF.bottomAnchor.constraint(equalTo: phoneNumberView.bottomAnchor, constant: -2)
        ])
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
        self.countryView?.layer.cornerRadius = (self.countryView?.bounds.height ?? 0)/2
        self.countryTF?.layer.cornerRadius = (self.countryTF?.bounds.height ?? 0)/2
        self.phoneNumberView?.layer.cornerRadius = (self.phoneNumberView?.bounds.height ?? 0)/2
        self.phoneNumberTF?.layer.cornerRadius = (self.phoneNumberTF?.bounds.height ?? 0)/2
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
    }

    private func addPhoneBorders() {
        self.countryView?.layer.borderColor = Colors.borderGray.cgColor
        self.countryView?.layer.borderWidth = 1.0

        self.phoneNumberView?.layer.borderColor = Colors.borderGray.cgColor
        self.phoneNumberView?.layer.borderWidth = 1.0
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

        guard let userId = self.userId, let email = self.email else {
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

        // Format phone number with country code
        var cleanPhone = phoneNumber
        if cleanPhone.hasPrefix("0") {
            cleanPhone = String(cleanPhone.dropFirst())
        }
        let fullPhoneNumber = "+\(country.code)\(cleanPhone)"

        self.attemptSignUp(userId: userId, firstName: firstName, lastName: lastName, email: email, phoneNumber: fullPhoneNumber, password: password)
    }

    private func attemptSignUp(userId: Int, firstName: String, lastName: String, email: String, phoneNumber: String, password: String) {
        LoginManager.shared.emailSignUp(userId: userId, firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, password: password) { (result) in
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
