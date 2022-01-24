//
//  SurveyViewController.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 18/10/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import UIKit


class SurveyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    
    
    //===============================
    // MARK: Properties
    //===============================
    
    var surveyUserStatusResponse: GetSurveyUserStatusResponse?
    var currentQuestionIndex: Int = 0
    var currentQuestion: JTSurveyQuestionWithAnswerOptions? {
        if let currentQ = self.surveyUserStatusResponse?.questions?[self.currentQuestionIndex] {
            return currentQ
        } else { return nil }
    }
    var currentAnswerType: JTSurveyAnswerType?
    var questionCount:Int {
        return self.surveyUserStatusResponse?.questions?.count ?? 0
    }
    
    var pickerData: [JTSurveyAnswer] = []
    var checklistData: [JTSurveyAnswer] = []
    
    var checkedAnswers: [JTSurveyAnswer] = []
    var customAnswer: String?
    var pickerAnswer: JTSurveyAnswer?
    var sliderAnswer: String?
    
    var userAnswers: [JTSurveyUserAnswer] = []
    
    
    
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
        if let title = self.surveyUserStatusResponse?.survey_title {
            self.surveyTitleLabel.text = title
        }
        if let subtitle = self.surveyUserStatusResponse?.stage_description {
            self.subtitleIntroLabel.text = subtitle
        }
        
        guard let firstQuestion = self.surveyUserStatusResponse?.questions?[self.currentQuestionIndex] else { return }

        DispatchQueue.main.async {
            self.setCardViewWithQuestion(question: firstQuestion, questionIndex: self.currentQuestionIndex)
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
            self.currentAnswerType = question.answer_type
            self.questionLabel.text = question.question
            self.questionNumberLabel.text = "\(questionIndex + 1)/\(self.questionCount)"
            
            self.picker.isHidden = question.answer_type != .picker
            self.slider.isHidden = question.answer_type != .ratingBar
            self.sliderValueLabel.isHidden = question.answer_type != .ratingBar
            self.checklistTableView.isHidden = question.answer_type != .multipleSelectionCheckbox && question.answer_type != .singleSelectionCheckboxWithOther
            
            switch question.answer_type {
            case .picker:
                self.pickerData = question.answer_options
                self.picker.reloadAllComponents()
            case .ratingBar:
                self.slider.value = 5.5
                self.sliderValueLabel.text = "5"
            case .multipleSelectionCheckbox:
                self.checklistData = question.answer_options
                self.checklistTableView.reloadData()
                break
            case .singleSelectionCheckboxWithOther:
                self.checklistData = question.answer_options
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
        /// did NOT answer the question
        if !self.didAnswerTheQuestion() {
            Utils.showAlertMessage(Strings.pleaseAnswerTheQuestion, viewControler: self)
            return
        }
        
        self.saveUserAnswer()
        /// Is last question
        if self.currentQuestionIndex == self.questionCount - 1 {
            self.sendUsersAnswers()
            Utils.showAlertMessage(Strings.thankYouVeryMuch.uppercased(), title: "", viewControler: self){ _ in
                self.dismiss(animated: true, completion: nil)
            }
        }
        /// Go to next question
        else {
            
            self.currentQuestionIndex += 1
            DispatchQueue.main.async {
                self.setCardViewWithQuestion(question: self.surveyUserStatusResponse!.questions![self.currentQuestionIndex], questionIndex: self.currentQuestionIndex)
                UIView.transition(with: self.cardView, duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
            }
        }
    }
    
    func saveUserAnswer(){
        guard let userID = self.surveyUserStatusResponse?.user else { return }
        guard let question = self.currentQuestion else { return }
        
        switch question.answer_type {
        case .multipleSelectionCheckbox:
            let allAnswers = self.checkedAnswers.compactMap{
                JTSurveyUserAnswer(question: $0.question, survey_answer: $0.id, user_answer_value: "", user: userID, survey: question.survey, stage: question.stage)
            }
            self.userAnswers.append(contentsOf: allAnswers)
            break
        case .picker:
            if let pickAnsw = self.pickerAnswer {
                let answer = JTSurveyUserAnswer(question: pickAnsw.question, survey_answer: pickAnsw.id, user_answer_value: "", user: userID, survey: question.survey, stage: question.stage)
                self.userAnswers.append(answer)
            }
            break
        case .ratingBar:
            if let rateAnswer = self.sliderAnswer {
                let answer = JTSurveyUserAnswer(question: question.id, survey_answer: nil, user_answer_value: rateAnswer, user: userID, survey: question.survey, stage: question.stage)
                self.userAnswers.append(answer)
            }
            break
        case .singleSelectionCheckboxWithOther:
            if let customText = self.customAnswer {
                let answer = JTSurveyUserAnswer(question: question.id, survey_answer: nil, user_answer_value: customText , user: userID, survey: question.survey, stage: question.stage)
                self.userAnswers.append(answer)
            }
            if let selectedAnswer = self.checkedAnswers.first {
                let answer = JTSurveyUserAnswer(question: question.id, survey_answer: selectedAnswer.id, user_answer_value: "", user: userID, survey: question.survey, stage: question.stage)
                self.userAnswers.append(answer)
            }
            break
        }
        print("self.userAnswers", self.userAnswers)
    }

    func sendUsersAnswers() {
        
        let answerDataToSend = self.userAnswers.map{$0.values}
        print("answerDataToSend", String(data: try! JSONSerialization.data(withJSONObject: answerDataToSend, options: .prettyPrinted), encoding: .utf8 )!)

        SurveyRepository.shared.postSurveyUserAnswers(answers: answerDataToSend) { result in
            print("***** postSurveyUserAnswers - successful", result)
        }
    
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let newValue = String(Int(sender.value))
        self.sliderValueLabel.text = newValue
        self.sliderAnswer = newValue
            
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
        return pickerData[row].answer
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
            cell.titleLabel.text = Strings.otherAnswer
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
            cell.titleLabel.text = self.checklistData[indexPath.row].answer
           
            if self.checkedAnswers.contains(where: { $0.id == self.checklistData[indexPath.row].id}) {
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

                if self.checkedAnswers.contains(where: { $0.id == answer.id}) {
                    guard let index = self.checkedAnswers.firstIndex(where: { $0.id == answer.id}) else { return }
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

