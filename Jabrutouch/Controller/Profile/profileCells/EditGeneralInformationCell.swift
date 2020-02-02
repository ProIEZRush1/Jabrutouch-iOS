//
//  EditGeneralInformationCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 27/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

protocol EditGeneralInformationCellDelegate: class {
    func parametersChanged(parameter: EditUserParameter, selected: Int)
}

enum textFieldPosition{
    case top , bottom
}

class EditGeneralInformationCell: UITableViewCell {
    
    @IBOutlet weak var contanerView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var contanerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contanerViewBottomConstraint: NSLayoutConstraint!
    
    var picker: UIPickerView!
    var toolbarView: UIToolbar!
    var parameters: [JTUserProfileParameter] = []
    var userEditParameter: EditUserParameter?
    weak var delegate: EditGeneralInformationCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.roundCorners()
        self.addBorders()
        self.initPicker()
        self.textField.textColor = #colorLiteral(red: 0.174, green: 0.17, blue: 0.338, alpha: 0.88)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func initPicker() {
        self.picker = UIPickerView()
        self.picker?.backgroundColor = Colors.offwhiteLight
        self.picker?.dataSource = self
        self.picker?.delegate = self
        self.toolbarView = Utils.keyboardToolBarWithDoneAndCancelButtons(tintColor: Colors.appBlue, target: self, doneSelector: #selector(self.keyboardDonePressed(_:)), cancelSelector: #selector(self.keyboardCancelPressed(_:)))
    }

    func setData(index: Int, editable: Bool, withPicker: Bool, withArrow: Bool, position: textFieldPosition, _ userEditParameter: EditUserParameter) {
        self.setParameters(userEditParameter: userEditParameter)
        self.setPicker(withPicker: withPicker)
        self.setPosition(position: position)
        self.setTextField(editable: editable, withArrow: withArrow)
    }
    
    func setParameters(userEditParameter: EditUserParameter) {
        self.userEditParameter = userEditParameter
        switch userEditParameter{
        case .community:
            self.parameters = EditUserParametersRepository.shared.parameters?.communities ?? []
        case .education:
            self.parameters = EditUserParametersRepository.shared.parameters?.education ?? []
        case .occupation:
            self.parameters = EditUserParametersRepository.shared.parameters?.occupation ?? []
        default:
            self.parameters = []
        }
    }
    
    func setPosition(position: textFieldPosition) {
        switch position {
        case .top:
            self.contanerViewBottomConstraint.constant = 5
            self.contanerViewTopConstraint.constant = 0
        case .bottom:
            self.contanerViewTopConstraint.constant = 5
            self.contanerViewBottomConstraint.constant = 0
        }
    }
    
    func setPicker(withPicker: Bool) {
        if withPicker {
            self.textField.inputView = self.picker
            self.textField.inputAccessoryView = self.toolbarView
        } else {
            self.textField.inputView = nil
            self.textField.inputAccessoryView = nil
        }
    }
    
    func setTextField(editable: Bool, withArrow: Bool) {
        switch withArrow {
        case true:
            let imgViewForDropDown = UIImageView()
            imgViewForDropDown.frame = CGRect(x: 0, y: 0, width: 30, height: 40)
            imgViewForDropDown.image = #imageLiteral(resourceName: "Black&BlueDownArrow")
            self.textField.rightView = imgViewForDropDown
            self.textField.rightViewMode = .always
        case false:
            self.textField.rightView = nil
        }
        switch editable {
        case true:
            self.textField.alpha = 1
            self.textField.isEnabled = true
        case false:
            self.textField.alpha = 0.5
            self.textField.isEnabled = false
        }
    }
    
    private func roundCorners() {
        self.contanerView.layer.cornerRadius = self.contanerView.bounds.height/2
        self.shadowView.layer.cornerRadius = self.shadowView.bounds.height/2
        self.textField.layer.cornerRadius = self.textField.bounds.height/2
    }
    
    private func addBorders() {
        self.shadowView.layer.borderColor = Colors.borderGray.cgColor
        self.shadowView.layer.borderWidth = 1.0
    }
    
        @objc func keyboardDonePressed(_ sender: Any) {
            guard let parameter = self.userEditParameter else { return }
            let index = self.picker.selectedRow(inComponent: 0)
            self.delegate?.parametersChanged(parameter: parameter, selected: index)
            
            self.textField.resignFirstResponder()
        }
        
        @objc func keyboardCancelPressed(_ sender: Any) {
            self.textField.resignFirstResponder()
            
        }

}
extension EditGeneralInformationCell: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch userEditParameter {
        case .country:
            return LocalizationManager.shared.getCountries().count
        case .community, .education, .occupation:
            return parameters.count
        case .religious:
            return 10
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch userEditParameter {
        case .country:
            let country = LocalizationManager.shared.getCountries()[row]
            return country.localizedName
        case .community, .education, .occupation:
            return self.parameters[row].name
        case .religious:
            return "\(row + 1)"
        default:
            return nil
        }
    }
}
