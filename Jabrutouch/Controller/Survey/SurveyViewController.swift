//
//  SurveyViewController.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 18/10/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import UIKit

class SurveyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource{

    
    
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
        setupPicker()
        setupTableview()
        roundCorners()
        setupSurvey()
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

        let q4 = JTSurveyQuestionWithAnswerOptions(id: 2, question: "Which masejtot have you already studied?", answerType: .singleSelectionCheckboxWithOther, answerOptions: ["Brajot","Erubin","Shabbat","Rosh Hashana", "Yoma", "Suca"])

        self.survey.questions.append(q1)
        self.survey.questions.append(q2)
        self.survey.questions.append(q3)
        self.survey.questions.append(q4)

        DispatchQueue.main.async {
            self.setCardViewWithQuestion(question: self.survey.questions[self.currentQuestionIndex], questionIndex: self.currentQuestionIndex)
        }

        
        
    }
    
    func setCardViewWithQuestion(question:JTSurveyQuestionWithAnswerOptions, questionIndex: Int){
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
                self.nextButton.setTitle("Finish!", for: .normal)
                self.nextButton.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3647058904, blue: 0.6705882549, alpha: 1)
            }
        }
      
    }
    
    //==========================================
    // MARK: Picker Delegate Functions
    //==========================================
    
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
        print(pickerData[row])
    }
    
    //=====================================================
    // MARK: Checklist Tableview Delegate Functions
    //=====================================================
    
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
       
//        let cell = tableView.dequeueReusableCell(withIdentifier: "surveyChecklistTVCell", for: indexPath) as! SurveyChecklistTVCell
        
        // ie: [index 0, index 1, index 2] , if indexPath.row == 3, then it's "other" option.
        if indexPath.row == self.checklistData.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "surveyCustomAnswerCell", for: indexPath) as! SurveyCustomAnswerCell
            cell.titleLabel.text = "Other - write an answer"
            cell.accessoryType = .disclosureIndicator
            cell.customAnswerTextField.isHidden = true
            return cell

        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "surveyChecklistTVCell", for: indexPath) as! SurveyChecklistTVCell
            cell.titleLabel.text = self.checklistData[indexPath.row]
            cell.accessoryType = .none
            return cell

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        var answer = ""
        if indexPath.row == self.checklistData.count {
            // is custom "Other" option, not in self.checklistData
            answer = "other"
        } else {
            answer = self.checklistData[indexPath.row]
        }

        switch self.currentAnswerType {
            case .multipleSelectionCheckbox:

                if self.checkedAnswers.contains(answer) {
                    guard let index = self.checkedAnswers.firstIndex(of: answer) else { return }
                    self.checkedAnswers.remove(at: index)
                    cell.accessoryType = .none
                }
                else {
                    self.checkedAnswers.append(answer)
                    cell.accessoryType = .checkmark
                }
            case .singleSelectionCheckboxWithOther:
                //is already selected, do nothing
                if self.checkedAnswers.contains(answer){
                    return
                }
                // if not selected, check if has previously checked answer and clear it
                if let previousAnswer = self.checkedAnswers.first {
                    if let index = self.checklistData.firstIndex(of: previousAnswer){
                        if let previousCell = tableView.cellForRow(at: IndexPath(row: index, section: indexPath.section)){
                            previousCell.accessoryType = .none
                        }
                    } else {
                        if previousAnswer == "other" {
                            if let previousCell = tableView.cellForRow(at: IndexPath(row: self.checklistData.count, section: indexPath.section)){
                                previousCell.accessoryType = .none
                            }
                        }
                    }
                }
                
                // if is the "Other" option.
                if indexPath.row == self.checklistData.count {
                    //MARK: TODO: pop open text input
                    if let custCell = cell as? SurveyCustomAnswerCell {
                        custCell.customAnswerTextField.isHidden = false
                        
                    }
                }
                

                // now clear selected previously answer and add new answer
                self.checkedAnswers = []
                self.checkedAnswers.append(answer)
                cell.accessoryType = .checkmark

                
            default:
                break
        }


        print(self.checkedAnswers, indexPath.row)

    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath){
        
    }

    
    //===============================
    // MARK: Actions
    //===============================
    @IBAction func nextButtonPressed(_ sender: Any) {
        if self.currentQuestionIndex == self.questionCount - 1 {
            self.dismiss(animated: true, completion: nil)
            
        } else {
            self.currentQuestionIndex += 1
                        DispatchQueue.main.async {
                            self.setCardViewWithQuestion(question: self.survey.questions[self.currentQuestionIndex], questionIndex: self.currentQuestionIndex)
                            UIView.transition(with: self.cardView, duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
                        }
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.sliderValueLabel.text = String(Int(sender.value))
    }
    
    
    

}

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

