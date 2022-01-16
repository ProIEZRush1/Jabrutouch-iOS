//
//  SurveyCustomAnswerCell.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 20/10/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import UIKit

protocol SurveyCustomAnswerCellDelegate {
    func saveCustomAnswer(answerText:String)
}

class SurveyCustomAnswerCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customAnswerTextField: UITextField!
    var delegate: SurveyCustomAnswerCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.customAnswerTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let answer = textField.text , !answer.isEmpty {
            self.delegate?.saveCustomAnswer(answerText: answer)
        }
        textField.resignFirstResponder()
        return true
    }

}
