//בעזרת ה׳ החונן לאדם דעת
//  ValidateVerificationCodeViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 17/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class ValidateVerificationCodeViewController: UIViewController {
    
    //============================================================
    // MARK: - Properties
    //============================================================
    
    private var activityView: ActivityView?
    var phoneNumber: String?
    //============================================================
    // MARK: - Outlets
    //============================================================
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var phoneNumberLabel: UILabel!
    @IBOutlet weak private var codeTF: UITextField!
    @IBOutlet weak private var backButton: UIButton!
    @IBOutlet weak private var resendButton: UIButton!
    
    //============================================================
    // MARK: - LifeCycle
    //============================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStrings()
    }
    
    //============================================================
    // MARK: - Setup
    //============================================================
    
    private func setStrings() {
        self.titleLabel.text = Strings.verificationCode
        self.subtitleLabel.text = Strings.enterTheVerificationCodeSentTo
        
        let resendButtonTitle = NSMutableAttributedString(string: Strings.resendCode, attributes: [NSAttributedString.Key.foregroundColor: Colors.textMediumBlue])
        let range = (Strings.resendCode as NSString).range(of: Strings.sendAgain)
        resendButtonTitle.addAttributes(
            [NSAttributedString.Key.underlineStyle:NSNumber(value: 1)],
            range: range)
        self.resendButton.setAttributedTitle(resendButtonTitle, for: .normal)
    }
    
    //============================================================
    // MARK: - @IBAction
    //============================================================
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resendCodeButtonPressed(_ sender: UIButton) {
        self.navigateToSignUp()
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
    
    //============================================================
    // MARK: - Navigation
    //============================================================
    
    private func navigateToSignUp() {
        self.performSegue(withIdentifier: "showSignUp", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
