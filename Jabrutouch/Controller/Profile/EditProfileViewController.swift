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
    
    var user: JTUser?
    var section: Int = 0
    private var datePicker: UIDatePicker?
    private var currentCountry = LocalizationManager.shared.getDefaultCountry()
    var myImagePicker: ImagePicker!
    var userEditParameters: JTUserProfileParameters?
    private var activityView: ActivityView?
    var image: UIImage?
    var imageChanged: Bool = false
    var passwordChanged: Bool = false
    var attemptToChangePassword: Bool = false
    var oldPassword: String?
    var newPassword: String?

    //============================================================
    // MARK: - Outlets
    //============================================================
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabelViewBottomConstrant: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    //============================================================
    // MARK: - LifeCycle
    //============================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.setText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.initDatePicker()
        user = UserRepository.shared.getCurrentUser()
        self.myImagePicker = ImagePicker(presentationController: self, delegate: self)
        if let parameters = EditUserParametersRepository.shared.parameters {
            userEditParameters = parameters
        } else {
            EditUserParametersRepository.shared.delegate = self
            self.showActivityView()
        }
        if let image = user?.profileImage {
           self.image = image
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
    
    private func setText() {
        self.doneButton.setTitle(Strings.done, for: .normal)
        self.titleLabel.text = Strings.editProfile
        
    }
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
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 50, right: 0)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    //============================================================
    // MARK: - @IBActions
    //============================================================
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.showActivityView()
        self.validatePassowrd()
        if self.attemptToChangePassword {
            self.removeActivityView()
            Utils.showAlertMessage("faild changing password", viewControler: self)
            return
        }
        guard var user = self.user else { return }
        if self.passwordChanged {
            self.changePassword(userId: user.id, oldPassword: self.oldPassword, newPassword: self.newPassword) { (result) in
                switch result{
                case .success(_):
                    if let image = self.image {
                        user.profileImage = image
                    }
                    if self.imageChanged {
                        user.imageLink = user.profileImageFileName //"profile_image_\(user.id).jpeg"
                        self.saveImageInS3{ (result: Result<Void, Error>) in
                            switch result {
                            case .success:
                                LoginManager.shared.setCurrentUserDetails(user) { (result) in
                                    self.removeActivityView()
                                    switch result {
                                    case .success(let user):
                                        UserRepository.shared.setProfileImage(image: self.image)
                                        DispatchQueue.main.async {
                                            self.user = user
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    case .failure(_):
                                        return
                                    }
                                }
                            case .failure(_):
                                self.removeActivityView()
                                Utils.showAlertMessage("faild saving image", viewControler: self)
                                return
                            }
                        }
                    } else {
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
                case .failure(_):
                    self.removeActivityView()
                    Utils.showAlertMessage("faild changing password", viewControler: self)
                    return
                }
            }
        } else {
            
            if let image = self.image {
                user.profileImage = image
            }
            if self.imageChanged {
                user.imageLink = user.profileImageFileName //"profile_image_\(user.id).jpeg"
                self.saveImageInS3 { (result: Result<Void, Error>) in
                    switch result {
                    case .success:
                        LoginManager.shared.setCurrentUserDetails(user) { (result) in
                            self.removeActivityView()
                            switch result {
                            case .success(let user):
                                DispatchQueue.main.async {
                                    self.user = user
                                    self.dismiss(animated: true, completion: nil)
                                }
                            case .failure(_):
                                self.removeActivityView()
                                Utils.showAlertMessage("faild updating profile", viewControler: self)
                                return
                            }
                        }
                    case .failure(_):
                        self.removeActivityView()
                        Utils.showAlertMessage("faild saving image", viewControler: self)
                        return
                    }
                }
            } else {
                LoginManager.shared.setCurrentUserDetails(user) { (result) in
                    self.removeActivityView()
                    switch result {
                    case .success(let user):
                        DispatchQueue.main.async {
                            self.user = user
                            self.dismiss(animated: true, completion: nil)
                        }
                    case .failure(_):
                        self.removeActivityView()
                        Utils.showAlertMessage("faild updating profile", viewControler: self)
                        return
                    }
                }
            }
        }
    }
    
    func validatePassowrd() {
        self.attemptToChangePassword = false
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 4)) as? EditPasswordCell
        
        guard let oldPassword = cell?.oldPasswordTextField.text else { return }
        guard let newPassword = cell?.newPasswordTextField.text else { return }
        
        if cell?.oldPasswordTextField.text?.isEmpty ?? true {
            self.attemptToChangePassword = true
            return
        }
        
        if oldPassword != UserDefaultsProvider.shared.currentPassword {
            Utils.showAlertMessage("Incorrect password", viewControler: self)
            self.attemptToChangePassword = true
            return
        }
        if let confirmNewPassword = cell?.confirmTextField.text {
            if newPassword != confirmNewPassword {
                Utils.showAlertMessage("new password, and confirm password must be identical", viewControler: self)
                self.attemptToChangePassword = true
                return
            }
        }
        
        self.oldPassword = oldPassword
        self.newPassword = newPassword
        self.passwordChanged = true
    }
        
    func changePassword(userId: Int, oldPassword: String?, newPassword: String?, completion:@escaping (Result<Void,Error>)->Void) {
        LoginManager.shared.changPassword(userId: userId, oldPassword: oldPassword, newPassword: newPassword) { (result) in
            switch result{
            case .success(_):
                UserDefaultsProvider.shared.currentPassword = newPassword
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
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
            cell.completionPercentage.text = "\(Int(count))% \(Strings.full)"
            cell.progressView.progress = progress
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editPersonalDetails") as? EditPersonalDetailsCell else { return UITableViewCell() }
            cell.firstNameTextField.text = user?.firstName
            cell.lastNameTextField.text = user?.lastName
            if self.image != nil {
                cell.profileImage.image = self.image
            } else {
                cell.profileImageButton.setTitle(Strings.addPhoto, for: .normal)
            }
            
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
                cell.textField.placeholder = Strings.country
                if !(user?.country ?? "").isEmpty {
                    if let countryName = LocalizationManager.shared.getCountry(regionCode: user?.country ?? "")?.localizedName {
                        cell.textField.text = countryName
                    }
                }
            case 2:
                cell.setData(index: indexPath.row, editable: false, withPicker: false, withArrow: false, position: .bottom, .phoneNumber)
                cell.textField.text = user?.phoneNumber

            case 3:
                cell.setData(index: indexPath.row, editable: true, withPicker: false, withArrow: true, position: .bottom, .birthday)
                cell.textField.tag = 2
                if self.user?.birthdayString == "" {
                    cell.textField.placeholder = Strings.birthday
                } else {
                    cell.textField.text = self.user?.birthdayString
                }
            case 4:
                cell.setData(index: indexPath.row, editable: true, withPicker: true, withArrow: true, position: .top, .community)
                if (self.user?.community?.name ?? "").isEmpty {
                    cell.textField.placeholder = Strings.community
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
                    cell.textField.placeholder = Strings.education
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
                cell.textField.placeholder = Strings.secondEmail
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
            cell.titleLabel.text = Strings.topicOfInterest
            cell.collectionView.reloadData()
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editPassword") as? EditPasswordCell else { return UITableViewCell() }
            cell.oldPasswordTextField.tag = 3
            cell.changePassowrdLabel.text = Strings.changePassword
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
            return CGFloat(numOfRowInterestCollectionView(indexPath: indexPath) * 42) + 70
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
    
    func saveImageInS3(completion: @escaping (Result<Void,Error>)->Void) {
        guard let user = self.user else { return }
        guard let url = user.profileImageFileURL else { return }
        
        AWSS3Provider.shared.handleFileUpload(fileUrl: url, fileName: user.profileImageFileName, contentType: "image/jpeg", bucketName: AWSS3Provider.appS3BucketName, progressBlock: { (progress) in
            print(progress)
        }) { (result:Result<String, Error>) in
            switch result {
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
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
            self.user?.country = LocalizationManager.shared.getCountries()[selected].code
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
        self.imageChanged = true
        self.image = image
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
