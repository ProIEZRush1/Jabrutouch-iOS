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
    
    
    
    
    
    
    
    
    //===============================
    // MARK: Lifecycle
    //===============================
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPicker()
        roundCorners()
        let years = ["1900", "1950","2000", "2020"]
        pickerData.append( contentsOf: years )
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
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
