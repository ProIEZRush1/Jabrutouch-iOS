//
//  DonationPopUpViewController.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 27/07/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class DonationPopUpViewController: UIViewController {
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var buttonBoxBlue: UIView!
    @IBOutlet weak var buttonTitleBlue: UILabel!
    @IBOutlet weak var buttonBlue: UIButton!
    
    @IBOutlet weak var buttonBoxRed: UIView!
    @IBOutlet weak var buttonTitleRed: UILabel!
    @IBOutlet weak var buttonRed: UIButton!
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    @IBOutlet weak var close: UIButton!
    
    var counter = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.selectView(0)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
           return .portrait
       }
    
    func setup(){
        self.popUpView.layer.cornerRadius = 15
        self.buttonBoxRed.layer.cornerRadius = 15
        self.buttonBoxBlue.layer.cornerRadius = 15
        self.close.isHidden = true
    }
    
    func firstView(){
        var userName = ""
        if let name = UserDefaultsProvider.shared.currentUser?.firstName { userName = name
        }
        firstLabel.textColor = UIColor(red: 1, green: 0.373, blue: 0.314, alpha: 1)
        firstLabel.font = Fonts.semiBold(size: 24)
        firstLabel.text = "\(Strings.donationPopUpTitle1) \(userName)!"
        
        let sentence = Strings.donationPopUpBody1
        let regularAttributes = [NSAttributedString.Key.font: Fonts.regularFont(size:19)]
        let largeAttributes = [NSAttributedString.Key.font: Fonts.mediumTextFont(size:19)]
        let attributedSentence = NSMutableAttributedString(string: sentence, attributes: regularAttributes)
        attributedSentence.setAttributes(largeAttributes, range: NSRange(location: sentence.count-15 , length: 15))
        secondLabel.attributedText = attributedSentence
        buttonTitleBlue.text = Strings.donationPopUpButton1.uppercased()
        
        buttonBoxRed.isHidden = true
    }
    
    func secondView(){
        firstLabel.text = Strings.donationPopUpTitle2
        firstLabel.font = Fonts.regularFont(size:19)
        firstLabel.textColor = UIColor(red: 0.174, green: 0.17, blue: 0.338, alpha: 0.88)
        
        secondLabel.text = Strings.donationPopUpBody2
        secondLabel.font = Fonts.boldFont(size:21)
        secondLabel.textColor = UIColor(red: 1, green: 0.373, blue: 0.314, alpha: 1)
        
        buttonTitleBlue.text = Strings.donationPopUpButton2.uppercased()
    }
    
    func thirdView(){
        var userName = ""
        if let name = UserDefaultsProvider.shared.currentUser?.firstName { userName = name
        }
        firstLabel.text = "\(userName)\(Strings.donationPopUpTitle3)"
        secondLabel.textColor = Colors.appBlue
        secondLabel.text = Strings.donationPopUpBody3
        
        buttonTitleRed.text = Strings.donationPopUpButton3.uppercased()
        
        buttonBoxBlue.isHidden = true
        buttonBoxRed.isHidden = false
        close.isHidden = false
    }
    
    func selectView(_ counter: Int){
        switch counter {
        case 0:
            firstView()
            case 1:
            secondView()
            case 2:
            thirdView()
        default:
            print("")
        }
    }
  //========================================
     // MARK: - @IBActions
     //========================================
    
     @IBAction func blueButtonPressed(_ sender: UIButton) {
         counter += 1
         selectView(counter)
     }
    
     @IBAction func redButtonPressed(_ sender: UIButton) {
         
     }

    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
