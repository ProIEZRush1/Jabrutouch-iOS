//
//  SurveyViewController.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 18/10/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import UIKit

class SurveyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    //===============================
    // MARK: Properties
    //===============================
    
    var survey:JTSurvey = JTSurvey()
    var currentQuestionIndex: Int = 0
    var questionCount:Int {
        return self.survey.questions.count
    }
    var pickerData: [String] = []
    
    
    
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
    @IBOutlet weak var checkListView: UIView!
    
    
    
    
    
    
    
    
    //===============================
    // MARK: Lifecycle
    //===============================
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPicker()
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
    
    fileprivate func roundCorners() {
        Utils.setViewShape(view: self.cardView,  viewCornerRadius: 18)
        Utils.setViewShape(view: self.nextButton,  viewCornerRadius: 18)
    }
 
    func setupSurvey(){
        let q1 = JTSurveyQuestionWithAnswerOptions(id: 0, question: "In what year were you born?", answerType: .picker, answerOptions: ["2000","2001","2002","2003","2004","2005"])
        let q2 = JTSurveyQuestionWithAnswerOptions(id: 1, question: "Rate our app please!", answerType: .ratingBar, answerOptions: nil)
        let q3 = JTSurveyQuestionWithAnswerOptions(id: 2, question: "When was your grandfather born?", answerType: .checkbox, answerOptions: ["1800","1801","1802","1803"])
        self.survey.questions.append(q1)
        self.survey.questions.append(q2)
        self.survey.questions.append(q3)
        
        DispatchQueue.main.async {
            self.setLabelsForQuestion(question: self.survey.questions[self.currentQuestionIndex], questionIndex: self.currentQuestionIndex)
        }

        
        
    }
    
    func setLabelsForQuestion(question:JTSurveyQuestionWithAnswerOptions, questionIndex: Int){
        DispatchQueue.main.async {
            self.currentQuestionIndex = questionIndex
            self.questionLabel.text = question.question
            self.questionNumberLabel.text = "\(questionIndex + 1)/\(self.questionCount)"
            
            self.picker.isHidden = question.answerType != .picker
            self.slider.isHidden = question.answerType != .ratingBar
            self.sliderValueLabel.isHidden = question.answerType != .ratingBar
            self.checkListView.isHidden = question.answerType != .checkbox
            
            switch question.answerType {
            case .picker:
                self.pickerData = question.answerOptions ?? []
                self.picker.reloadAllComponents()
            case .ratingBar:
                self.slider.value = 5.5
                self.sliderValueLabel.text = "5"
            case .checkbox:
                let checkList = CheckBoxListView(frame: self.checkListView.frame)
                checkList.setupCheckBoxes(data: question.answerOptions ?? [] )
                self.checkListView.addSubview(checkList)
                self.view.layoutIfNeeded()
            default:
                break
            }
            
            if self.currentQuestionIndex == self.questionCount - 1{
                //last question
                self.nextButton.setTitle("Finish!", for: .normal)
                self.nextButton.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3647058904, blue: 0.6705882549, alpha: 1)
            }
        }
      
    }
    //===============================
    // MARK: Picker Delegate Functions
    //===============================
    
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
    
    
    
    
    //===============================
    // MARK: Actions
    //===============================
    @IBAction func nextButtonPressed(_ sender: Any) {
        if self.currentQuestionIndex == self.questionCount - 1 {
            self.dismiss(animated: true, completion: nil)
            
        } else {
            self.currentQuestionIndex += 1
                        DispatchQueue.main.async {
                            self.setLabelsForQuestion(question: self.survey.questions[self.currentQuestionIndex], questionIndex: self.currentQuestionIndex)
                            UIView.transition(with: self.cardView, duration: 1, options: .transitionFlipFromRight, animations: nil, completion: nil)
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
    case checkbox
    case ratingBar
    case complexPicker
}

