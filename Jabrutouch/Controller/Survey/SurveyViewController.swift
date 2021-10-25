//
//  SurveyViewController.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 18/10/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import UIKit


class JTSurvey {
    var id: Int = 0
    var title: String = "Survey 1"
    var subtitleIntro:String = "Please answer these short questions so we can serve you better."
    var questions:[JTSurveyQuestionWithAnswerOptions] = []
}

class JTSurveyQuestionWithAnswerOptions {
    var id:Int
    var question: String
    var answerType:JTSurveyAnswerType
    var answerOptions: [String]?
    
    init(id:Int, question:String, answerType:JTSurveyAnswerType, answerOptions: [String]?) {
        self.id = id
        self.question = question
        self.answerType = answerType
        self.answerOptions = answerOptions
    }
}
enum JTSurveyAnswerType {
    case picker
    case multipleSelectionCheckbox
    case ratingBar
    case singleSelectionCheckboxWithOther
}

class SurveyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    
    
    //===============================
    // MARK: Properties
    //===============================
    
    var survey:JTSurvey = JTSurvey()
    var currentQuestionIndex: Int = 0
    var currentAnswerType: JTSurveyAnswerType?
    var questionCount:Int {
        return self.survey.questions.count
    }
    var pickerData: [String] = []
    var checklistData: [String] = []
    var checkedAnswers: [String] = []
    var customAnswer: String?
    var pickerAnswer: String?
    var sliderAnswer: String?
    
    
    
    //===============================
    // MARK: Outlets
    //===============================
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var surveyTitleLabel: UILabel!
    @IBOutlet weak var subtitleIntroLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderValueLabel: UILabel!
    @IBOutlet weak var checklistTableView: UITableView!
    
    
    
    
    
    
    
    
    //===============================
    // MARK: Lifecycle
    //===============================

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
        self.setupTableview()
        self.roundCorners()
        self.setupSurvey()
        self.observeKeyboard()
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name:  UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:  UIResponder.keyboardWillHideNotification, object: nil)
    }

    //===============================
    // MARK: Setup
    //===============================
    
    fileprivate func setupPicker() {
        self.picker.delegate = self
        self.picker.dataSource = self
    }
    
    fileprivate func setupTableview() {
        self.checklistTableView.delegate = self
        self.checklistTableView.dataSource = self
    }
    
    fileprivate func roundCorners() {
        Utils.setViewShape(view: self.cardView,  viewCornerRadius: 18)
        Utils.setViewShape(view: self.nextButton,  viewCornerRadius: 18)
    }
 
    func setupSurvey(){
        let q1 = JTSurveyQuestionWithAnswerOptions(id: 0, question: "In what year were you born?", answerType: .picker, answerOptions: ["2000","2001","2002","2003","2004","2005"])
        let q2 = JTSurveyQuestionWithAnswerOptions(id: 1, question: "Rate our app please!", answerType: .ratingBar, answerOptions: nil)
        let q3 = JTSurveyQuestionWithAnswerOptions(id: 2, question: "When was your grandfather born?", answerType: .multipleSelectionCheckbox, answerOptions: ["1800","1801","1802","1803"])

        let q4 = JTSurveyQuestionWithAnswerOptions(id: 3, question: "Which masejtot have you already studied?", answerType: .singleSelectionCheckboxWithOther, answerOptions: ["Brajot","Erubin","Shabbat","Rosh Hashana", "Yoma", "Suca"])

        self.survey.questions.append(q1)
        self.survey.questions.append(q2)
        self.survey.questions.append(q3)
        self.survey.questions.append(q4)

        DispatchQueue.main.async {
            self.setCardViewWithQuestion(question: self.survey.questions[self.currentQuestionIndex], questionIndex: self.currentQuestionIndex)
        }

        
        
    }
    
    fileprivate func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func setCardViewWithQuestion(question:JTSurveyQuestionWithAnswerOptions, questionIndex: Int){
        self.clearPreviousAnswers()
        DispatchQueue.main.async {
            self.currentQuestionIndex = questionIndex
            self.currentAnswerType = question.answerType
            self.questionLabel.text = question.question
            self.questionNumberLabel.text = "\(questionIndex + 1)/\(self.questionCount)"
            
            self.picker.isHidden = question.answerType != .picker
            self.slider.isHidden = question.answerType != .ratingBar
            self.sliderValueLabel.isHidden = question.answerType != .ratingBar
            self.checklistTableView.isHidden = question.answerType != .multipleSelectionCheckbox && question.answerType != .singleSelectionCheckboxWithOther
            
            switch question.answerType {
            case .picker:
                self.pickerData = question.answerOptions ?? []
                self.picker.reloadAllComponents()
            case .ratingBar:
                self.slider.value = 5.5
                self.sliderValueLabel.text = "5"
            case .multipleSelectionCheckbox:
                self.checklistData = question.answerOptions ?? []
                self.checklistTableView.reloadData()
                break
            case .singleSelectionCheckboxWithOther:
                self.checklistData = question.answerOptions ?? []
                self.checklistTableView.reloadData()
                break
            }
            
            if self.currentQuestionIndex == self.questionCount - 1{
                //last question
                self.nextButton.setTitle(Strings.send.uppercased(), for: .normal)
                self.nextButton.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3647058904, blue: 0.6705882549, alpha: 1)
            }
        }
      
    }
    
    
    
    
    //===============================
    // MARK: Actions
    //===============================
    @IBAction func nextButtonPressed(_ sender: Any) {
        if !self.didAnswerTheQuestion() {
            Utils.showAlertMessage(Strings.pleaseAnswerTheQuestion, viewControler: self)
            return
        }
        /// Is last question
        if self.currentQuestionIndex == self.questionCount - 1 {
            Utils.showAlertMessage(Strings.thankYouVeryMuch.uppercased(), title: "", viewControler: self){ _ in
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        /// Go to next question
        else {
            
            self.currentQuestionIndex += 1
            DispatchQueue.main.async {
                self.setCardViewWithQuestion(question: self.survey.questions[self.currentQuestionIndex], questionIndex: self.currentQuestionIndex)
                UIView.transition(with: self.cardView, duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
            }
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.sliderValueLabel.text = String(Int(sender.value))
        self.sliderAnswer = String(Int(sender.value))
    }
    
    func clearPreviousAnswers() {
        self.pickerAnswer = nil
        self.sliderAnswer = nil
        self.checkedAnswers = []
        self.customAnswer = nil
    }
    
    
    func didAnswerTheQuestion() -> Bool {
        switch self.currentAnswerType {
        case .multipleSelectionCheckbox:
            if !self.checkedAnswers.isEmpty {
                return true
            }
        case .picker:
            if self.pickerAnswer != nil {
                return true
            }
        case .ratingBar:
            if self.sliderAnswer != nil {
                return true
            }
        case .singleSelectionCheckboxWithOther:
            if (!self.checkedAnswers.isEmpty) || (self.customAnswer != nil) {
                return true
            }
        default:
            break
        }
        return false
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        self.view.window?.frame.origin.y = -1 * self.getKeyboardHeight(notification: notification)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.window?.frame.origin.y != 0 {
            self.view.window?.frame.origin.y += self.getKeyboardHeight(notification: notification)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            return keyboardHeight
        }
        return 0
    }

}


//==========================================
// MARK: Picker Delegate Functions
//==========================================
extension SurveyViewController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pickerAnswer = pickerData[row]
        print(pickerData[row])
    }
}


//==========================================
// MARK: SurveyCustomAnswerCellDelegate
//==========================================
extension SurveyViewController: SurveyCustomAnswerCellDelegate {
    func saveCustomAnswer(answerText: String) {
        self.customAnswer = answerText
        self.checkedAnswers = []
        self.checklistTableView.reloadData()
    }
}


//=====================================================
// MARK: Checklist Tableview Delegate Functions
//=====================================================
extension SurveyViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.currentAnswerType {
        case .multipleSelectionCheckbox:
            return self.checklistData.count
        case .singleSelectionCheckboxWithOther:
            // add one more row for "Other" option.
            return self.checklistData.count + 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// ie: [index 0, index 1, index 2] , if indexPath.row == 3, then it's "other" option.
        /// Custom SurveyCustomAnswerCell
        if indexPath.row == self.checklistData.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "surveyCustomAnswerCell", for: indexPath) as! SurveyCustomAnswerCell
            cell.delegate = self
            cell.titleLabel.text = "Other - write an answer"
            if let _ = self.customAnswer {
                cell.accessoryType = .checkmark
                cell.customAnswerTextField.text = self.customAnswer
            } else {
                cell.accessoryType = .none
                cell.customAnswerTextField.text = ""
            }
            return cell
        }
        else {
            /// Regular SurveyChecklistTVCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "surveyChecklistTVCell", for: indexPath) as! SurveyChecklistTVCell
            cell.titleLabel.text = self.checklistData[indexPath.row]
           
            if self.checkedAnswers.contains(self.checklistData[indexPath.row]) {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
            
            return cell

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.row == self.checklistData.count {
            /// is custom "Other" option, not in self.checklistData
            /// is saved only if customAnswer entered into textField
            /// handled by SurveyCustomAnswerCellDelegate
            
            /// MUST RETURN HERE SO WE DON'T GET AN OUT OF BOUNDS INDEX WHEN LOOKING FOR ANSWER IN  self.checklistData[indexPath.row]
            return
        }
        let answer = self.checklistData[indexPath.row]


        switch self.currentAnswerType {
            case .multipleSelectionCheckbox:

                if self.checkedAnswers.contains(answer) {
                    guard let index = self.checkedAnswers.firstIndex(of: answer) else { return }
                    self.checkedAnswers.remove(at: index)
                }
                else {
                    self.checkedAnswers.append(answer)
                }
            case .singleSelectionCheckboxWithOther:
                self.checkedAnswers = []
                self.customAnswer = nil
                self.checkedAnswers.append(answer)
                /// saving OTHER custom answer is handled by SurveyCustomAnswerCellDelegate which is called inside textFieldShouldReturn inside SurveyCustomAnswerCell.
            default:
                break
        }
        
        tableView.reloadData()
        print(self.checkedAnswers, indexPath.row)
    }


}

