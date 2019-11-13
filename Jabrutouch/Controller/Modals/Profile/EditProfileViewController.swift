//
//  EditProfileViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 10/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //============================================================
    // MARK: - Properties
    //============================================================
    var birthday: String?
    var datePicker: UIDatePicker?
    var user: JTUser?
    private var countriesPicker: UIPickerView?
    private var currentCountry = LocalizationManager.shared.getDefaultCountry()
    
//    var selectedDay:Int = 0
//    var selectedMonth:Int = 0
//    var selectedYear:Int = 0
//
//    var birthdate:String {
//        let selectedDay =  self.selectedDay < 10 ? "0\(self.selectedDay)" : "\(self.selectedDay)"
//        let selectedMonth =  self.selectedMonth < 10 ? "0\(self.selectedMonth)" : "\(self.selectedMonth)"
//        return "\(selectedDay)-\(selectedMonth)-\(selectedYear)"
//    }
//
    //============================================================
    // MARK: - Outlets
    //============================================================
    @IBOutlet weak var tableView: UITableView!
    
    //============================================================
    // MARK: - LifeCycle
    //============================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.initCountriesPicker()
        
        user = UserDefaultsProvider.shared.currentUser
    }
    
    //============================================================
    // MARK: - Setup
    //============================================================
    
    private func initCountriesPicker() {
        self.countriesPicker = UIPickerView()
        self.countriesPicker?.backgroundColor = Colors.offwhiteLight
        self.countriesPicker?.dataSource = self
        self.countriesPicker?.delegate = self
    }
    
    
    //============================================================
    // MARK: - @IBActions
    //============================================================
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
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
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        self.birthday = dateFormatter.string(from: sender.date)
    }
    
    @objc func donePressed(_ sender: UITextField) {
//        guard let date = self.datePicker?.date else { return }
//        let calendar = Calendar(identifier: .gregorian)
        //        let components = calendar.dateComponents([.day,.month, .year], from: date)
//        self.selectedDay = calendar.component(.day, from: date)
//        self.selectedMonth = calendar.component(.month, from: date)
//        self.selectedYear = calendar.component(.year, from: date)

//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yyyy"
        sender.resignFirstResponder()
    }
//
//    @objc func datePickerValueChanged(_ sender:UIDatePicker) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yyyy"
//        //        dateOfBirthTF.text = dateFormatter.string(from: sender.date)
//    }
    //============================================================
    // MARK: - tabel view
    //============================================================
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 9
        case 3:
            return 1
        case 4:
            return 1
        default:
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "completionProgress") as? CompletionProgressCell else { return UITableViewCell() }
            let count = 60.0
            let progress = CGFloat(count/100)
            cell.completionPercentage.text = "\(Int(count))% Full"
            cell.progressView.progress = progress
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editPersonalDetails") as? EditPersonalDetailsCell else { return UITableViewCell() }
            cell.firstNameTextField.text = user?.firstName
            cell.lastNameTextField.text = user?.lastName
            cell.profileImage.image = #imageLiteral(resourceName: "Avatar")
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editGeneralInformation") as? EditGeneralInformationCell else { return UITableViewCell() }
            
            switch indexPath.row {
            case 0:
                cell.titleLabel.isHidden = false
                cell.titleLabel.text = user?.email
                cell.titleLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                cell.arrowImage.isHidden = true
                cell.textField.isHidden = true
                cell.contanerViewTopConstraint.constant = 5
            case 1:
                cell.titleLabel.isHidden = false
                cell.titleLabel.text = LocalizationManager.shared.getDefaultCountry()?.fullDisplayName
                cell.titleLabel.textColor = #colorLiteral(red: 0.17, green: 0.17, blue: 0.34, alpha: 0.88)
                cell.arrowImage.isHidden = false
                cell.textField.isHidden = true
                cell.contanerViewBottomConstraint.constant = 5
            case 2:
                cell.titleLabel.isHidden = false
                cell.titleLabel.text = user?.phoneNumber
                cell.titleLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                cell.arrowImage.isHidden = true
                cell.textField.isHidden = true
                cell.contanerViewTopConstraint.constant = 5
            case 3:
                cell.titleLabel.isHidden = true
                cell.titleLabel.textColor = #colorLiteral(red: 0.17, green: 0.17, blue: 0.34, alpha: 0.88)
                cell.arrowImage.isHidden = true
                cell.textField.tag = 1
                if self.user?.birthdayString == "" {
                    cell.textField.text = "Birthday"
                } else {
                    cell.textField.text = self.user?.birthdayString
                }
//                cell.textField.text = self.birthdate
                cell.textField.isHidden = false
                cell.contanerViewTopConstraint.constant = 5
            case 4:
                cell.titleLabel.isHidden = false
                cell.titleLabel.text = "Community"
                cell.titleLabel.textColor = #colorLiteral(red: 0.17, green: 0.17, blue: 0.34, alpha: 0.88)
                cell.arrowImage.isHidden = false
                cell.textField.isHidden = true
                cell.contanerViewBottomConstraint.constant = 5
            case 5:
                cell.titleLabel.isHidden = false
                cell.titleLabel.text = "Religious Level"
                cell.titleLabel.textColor = #colorLiteral(red: 0.17, green: 0.17, blue: 0.34, alpha: 0.88)
                cell.arrowImage.isHidden = false
                cell.textField.isHidden = true
                cell.contanerViewBottomConstraint.constant = 5
            case 6:
                cell.titleLabel.isHidden = false
                cell.titleLabel.text = "Education"
                cell.titleLabel.textColor = #colorLiteral(red: 0.17, green: 0.17, blue: 0.34, alpha: 0.88)
                cell.arrowImage.isHidden = false
                cell.textField.isHidden = true
                cell.contanerViewBottomConstraint.constant = 5
            case 7:
                cell.titleLabel.isHidden = false
                cell.titleLabel.text = "Occupation"
                cell.titleLabel.textColor = #colorLiteral(red: 0.17, green: 0.17, blue: 0.34, alpha: 0.88)
                cell.arrowImage.isHidden = false
                cell.textField.isHidden = true
                cell.contanerViewBottomConstraint.constant = 5
            case 8:
                cell.textField.isHidden = false
                cell.titleLabel.isHidden = true
                cell.arrowImage.isHidden = true
                cell.textField.textColor = #colorLiteral(red: 0.17, green: 0.17, blue: 0.34, alpha: 0.88)
                cell.textField.text = "Second Email Address"
                cell.contanerViewTopConstraint.constant = 5
            default:
                break
            }
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InterestsCell") as? InterestsCell else { return UITableViewCell() }
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editPassword") as? EditPasswordCell else { return UITableViewCell() }
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 60
        case 1:
            return 120
        case 2:
            return 50
        case 3:
            return 200
        case 4:
            return 300
        default:
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0, 1, 3, 4:
            break
        case 2:
            switch indexPath.row {
            case 0, 2, 3:
                break
            case 1:
                // open countries picker
                print("country selected")
            case 4:
                // open community picker
                print("community selected")
            case 5:
                // open religious level picker
                print("religious level selected")
            case 6:
                // open education picker
                print("education selected")
            case 7:
                // open occupation picker
                print("occupation selected")
            default:
                break
            }
        default:
            break
        }
    }
    
}

extension EditProfileViewController: UIPickerViewDelegate {
    
}

extension EditProfileViewController: UIPickerViewDataSource {
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

extension EditProfileViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            let datePickerView = UIDatePicker()
            datePickerView.datePickerMode = .date
            textField.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)

//            self.datePicker = UIDatePicker()
//            self.datePicker?.calendar = Calendar(identifier: .gregorian)
//            self.datePicker?.datePickerMode = .date
//            self.datePicker?.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
//            textField.inputView = self.datePicker
//
            let keyboardToolbar = UIToolbar()
            keyboardToolbar.sizeToFit()
            let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed(_:)))
            keyboardToolbar.items = [flexBarButton, doneBarButton]
            textField.inputAccessoryView = keyboardToolbar
            
        }
        
    }
}

