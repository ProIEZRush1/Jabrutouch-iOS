//
//  EditProfileViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 10/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //============================================================
    // MARK: - Properties
    //============================================================
//    var birthday: String?
    var user: JTUser?
    var section: Int = 0
    private var datePicker: UIDatePicker?
//    private var countriesPicker: UIPickerView!
    private var currentCountry = LocalizationManager.shared.getDefaultCountry()
//    private var birthdate = ""
    var myImagePicker: ImagePicker!
    var userEditParameters: JTUserProfileParameters?
    private var activityView: ActivityView?

    //============================================================
    // MARK: - Outlets
    //============================================================
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabelViewBottomConstrant: NSLayoutConstraint!
    
    //============================================================
    // MARK: - LifeCycle
    //============================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        self.initCountriesPicker()
        self.initDatePicker()
        user = UserRepository.shared.getCurrentUser()

        self.myImagePicker = ImagePicker(presentationController: self, delegate: self)
        if let parameters = EditUserParametersRepository.shared.parameters {
            userEditParameters = parameters
        } else {
            EditUserParametersRepository.shared.delegate = self
            self.showActivityView()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let indexPath = IndexPath(row: 0, section: self.section)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
    }
        
    //============================================================
    // MARK: - Setup
    //============================================================
    
//    private func initCountriesPicker() {
//        self.countriesPicker = UIPickerView()
//        self.countriesPicker?.backgroundColor = Colors.offwhiteLight
//        self.countriesPicker?.dataSource = self
//        self.countriesPicker?.delegate = self
//    }
    
    private func initDatePicker() {
        self.datePicker = UIDatePicker()
        self.datePicker?.backgroundColor = Colors.offwhiteLight

    }
    
    
    //============================================================
    // MARK: - @IBActions
    //============================================================
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        guard let user  = self.user else { return }
        self.showActivityView()
        
        LoginManager.shared.setCurrentUserDetails(user) { (result) in
            self.removeActivityView()
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.user = user
                    self.dismiss(animated: true, completion: nil)
                }
            case .failure(_):
                return
            }
        }
    }
    // TODO: - Fix it
    @objc func keyboardDonePressed(_ sender: Any) {
//        if let index = self.countriesPicker?.selectedRow(inComponent: 0) {
//            self.currentCountry = LocalizationManager.shared.getCountries()[index]
//        }
        self.view.endEditing(true)
        self.tableView.reloadData()
    }
    
    @objc func keyboardCancelPressed(_ sender: Any) {
        self.view.endEditing(true)
        
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        self.user?.birthdayString = dateFormatter.string(from: sender.date)
    }
    
    @objc func donePressed(_ sender: UITextField) {
        guard let date = self.datePicker?.date else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
//        self.birthdate = dateFormatter.string(from: date)
        self.user?.birthdayString = dateFormatter.string(from: date)
        self.view.endEditing(true)
        self.tableView.reloadData()
    }
    
    @objc func profileImageButtonPressed(_ sender: UIButton){
        self.myImagePicker.present(from: sender)
    }

    //============================================================
    // MARK: - table view
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
            return 7
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
            let count = user?.profilePercent ?? 0
            let progress = CGFloat(count)/100
            cell.completionPercentage.text = "\(Int(count))% Full"
            cell.progressView.progress = progress
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editPersonalDetails") as? EditPersonalDetailsCell else { return UITableViewCell() }
            cell.firstNameTextField.text = user?.firstName
            cell.lastNameTextField.text = user?.lastName
            cell.profileImage.image = user?.profileImage ?? #imageLiteral(resourceName: "Avatar")
            
            cell.profileImageButton.addTarget(self, action: #selector(profileImageButtonPressed(_:)), for: .touchUpInside)
           
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editGeneralInformation") as? EditGeneralInformationCell else { return UITableViewCell() }
            cell.delegate = self
            switch indexPath.row {
            case 0:
                cell.setData(index: indexPath.row, editable: false, withPicker: false, withArrow: false, position: .bottom, .email)
                cell.textField.text = user?.email
            case 1:
                cell.setData(index: indexPath.row, editable: true, withPicker: true, withArrow: true, position: .top, .country)
                cell.textField.placeholder = "Country"
                if !(user?.country ?? "").isEmpty {
                    cell.textField.text = user?.country
                }
            case 2:
                cell.setData(index: indexPath.row, editable: false, withPicker: false, withArrow: false, position: .bottom, .phoneNumber)
                cell.textField.text = user?.phoneNumber

            case 3:
                cell.setData(index: indexPath.row, editable: true, withPicker: false, withArrow: true, position: .bottom, .birthday)
                cell.textField.tag = 2
                if self.user?.birthdayString == "" {
                    cell.textField.placeholder = "Birthday"
                } else {
                    cell.textField.text = self.user?.birthdayString
                }
            case 4:
                cell.setData(index: indexPath.row, editable: true, withPicker: true, withArrow: true, position: .top, .community)
                if (self.user?.community?.name ?? "").isEmpty {
                    cell.textField.placeholder = "Community"
                } else {
                    cell.textField.text = self.user?.community?.name
                }
//            case 5:
//                cell.setData(index: indexPath.row, editable: true, withPicker: true, withArrow: true, position: .top, .religious)
//                if let religious = self.user?.religiousLevel {
//                    cell.textField.text = "\(religious)"
//                } else {
//                    cell.textField.placeholder = "Religious Level"
//                }
            case 5:
                cell.setData(index: indexPath.row, editable: true, withPicker: true, withArrow: true, position: .top, .education)
                if (self.user?.education?.name ?? "").isEmpty {
                    cell.textField.placeholder = "Education"
                } else {
                    cell.textField.text = self.user?.education?.name
                }
//            case 7:
//                cell.setData(index: indexPath.row, editable: true, withPicker: true, withArrow: true, position: .top, .occupation)
//                if (self.user?.occupation?.name ?? "").isEmpty {
//                    cell.textField.placeholder = "Occupation"
//                } else {
//                    cell.textField.text = self.user?.occupation?.name
//                }
            case 6:
                cell.setData(index: indexPath.row, editable: true, withPicker: false, withArrow: false, position: .bottom, .secondEmail)
                cell.textField.textContentType = .emailAddress
                cell.textField.keyboardType = .emailAddress
                cell.textField.placeholder = "Second Email Address"
                if !(self.user?.secondEmail ?? "").isEmpty {
                    cell.textField.text = self.user?.secondEmail
                }
                cell.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            default:
                break
            }
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InterestsCell") as? InterestsCell else { return UITableViewCell() }
            cell.interests = self.user?.interest ?? []
            cell.collectionView.reloadData()
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editPassword") as? EditPasswordCell else { return UITableViewCell() }
            cell.oldPasswordTextField.tag = 3
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
            return 66
        case 3:
            return CGFloat(numOfRowInterestCollectionView(indexPath: indexPath) * 42) + 60
        case 4:
            return 300
        default:
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
    
    func numOfRowInterestCollectionView(indexPath: IndexPath) -> Int {
        let collectionWidth = self.tableView.bounds.width - 30
        let space: CGFloat = 10
        var rows = (self.user?.interest ?? []).isEmpty ? 0 : 1
        var x: CGFloat = 0
        for interest in self.user?.interest ?? [] {
            let itemWidth = NSString(string: interest.name).size(withAttributes: [.font : Fonts.mediumTextFont(size: 14)]).width + 40.0
            if x + itemWidth > collectionWidth {
                x = itemWidth + space
                rows += 1
            } else {
                x += itemWidth + space
            }
        }
        return rows
    }
    
    func saveImageInS3() {
//        AWSS3Provider.shared.handleFileUpload(fileUrl: <#T##URL#>, fileName: <#T##String#>, contentType: <#T##String#>, bucketName: AWSS3Provider.appS3BucketName, progressBlock: <#T##((Progress) -> Void)?##((Progress) -> Void)?##(Progress) -> Void#>, completion: <#T##((Result<String, Error>) -> Void)?##((Result<String, Error>) -> Void)?##(Result<String, Error>) -> Void#>)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectInterest" {
            if let selectInterestViewController = segue.destination as? SelectInterestViewController {
                selectInterestViewController.user = self.user
                selectInterestViewController.delegate = self
            }
        }
    }

}

extension EditProfileViewController: EditGeneralInformationCellDelegate {
    func parametersChanged(parameter: EditUserParameter, selected: Int) {
        switch parameter {
        case .country:
            self.user?.country = LocalizationManager.shared.getCountries()[selected].localizedName
            self.currentCountry = LocalizationManager.shared.getCountries()[selected]
        case .community:
            guard let parameterObject = self.userEditParameters?.communities[selected] else { return }
            self.user?.community = JTCommunity(editUserParameter: parameterObject)
        case .religious:
            self.user?.religiousLevel = selected + 1
        case .education:
            guard let parameterObject = self.userEditParameters?.education[selected] else { return }
            self.user?.education = parameterObject
        case .occupation:
            guard let parameterObject = self.userEditParameters?.occupation[selected] else { return }
            self.user?.occupation = parameterObject
        default:
            return
        }
        self.tableView.reloadData()
    }
    
}

extension EditProfileViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tableView.contentOffset.y = 0.0
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField.tag ==  1 {
//            if let pickerView = self.countriesPicker {
//                textField.inputView = pickerView
//                textField.inputAccessoryView = accessoryView
//            }
//        }
        
        if textField.tag == 2 {
            
            if let datePickerView = self.datePicker {

                datePickerView.datePickerMode = .date
                datePickerView.maximumDate = Date()
                textField.inputView = datePickerView
                datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
                let keyboardToolbar = UIToolbar()
                keyboardToolbar.sizeToFit()
                let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed(_:)))
                keyboardToolbar.items = [flexBarButton, doneBarButton]
                textField.inputAccessoryView = keyboardToolbar
            }
            
        }
        if textField.tag == 3 {
            self.tableView.contentOffset.y += 300
        }
        
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        if !(sender.text?.isEmpty ?? false) {
            self.user?.secondEmail = sender.text ?? ""
        }
    }
}

extension EditProfileViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        if let url = self.user?.profileImageFileURL, let data = image?.pngData() {
            do {
               try  FilesManagementProvider.shared.overwriteFile(path: url, data: data)
            }
            catch {
                
            }
        }
        self.user?.profileImage = image
        self.user?.imageLink = "link"
        self.tableView.reloadData()
        
    }
}

extension EditProfileViewController: EditUserParametersRepositoryDelegate {
    func parametersLoaded(parameters: JTUserProfileParameters) {
        self.userEditParameters = parameters
        self.removeActivityView()
        self.tableView.reloadData()
    }
}

extension EditProfileViewController: SelectInterestViewControllerDelegate {
    func interestsSelected(interests: [JTUserProfileParameter]) {
        self.user?.interest = interests
        self.tableView.reloadData()
    }
}
