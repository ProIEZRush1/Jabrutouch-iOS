//בעזרת ה׳ החונן לאדם דעת
//  VerificationViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 17/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class VerificationViewController: UIViewController {
    
    //============================================================
    // MARK: - Properties
    //============================================================
    
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
    
    //============================================================
    // MARK: - LifeCycle
    //============================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStrings()
        self.roundCorners()
        self.addBorders()
        self.initCountriesPicker()
        self.setInputViews()
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
    }
    
    private func addBorders() {
        self.countryTF.layer.borderColor = Colors.borderGray.cgColor
        self.countryTF.layer.borderWidth = 1.0
        
        self.phoneNumberTF.layer.borderColor = Colors.borderGray.cgColor
        self.phoneNumberTF.layer.borderWidth = 1.0
    }
    
    private func initCountriesPicker() {
        self.countriesPicker = UIPickerView()
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
        // TODO: - Pending real implementation
        self.navigateToVerificatonCodeViewController()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //============================================================
    // MARK: - Navigation
    //============================================================
    
    private func navigateToVerificatonCodeViewController() {
        self.performSegue(withIdentifier: "showVerificationCode", sender: nil)
    }
}

extension VerificationViewController: UIPickerViewDelegate {
    
}

extension VerificationViewController: UIPickerViewDataSource {
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

extension VerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === self.countryTF {
            return false
        }
        return true
    }
}
