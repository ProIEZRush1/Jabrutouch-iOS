//
//  NotDonateAlert.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 26/04/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class NotDonateAlert: UIViewController, DonatedAlertDelegate {
     func didDismiss() {
        }
        
        
         //====================================================
            // MARK: - @IBOutlets
           //====================================================
        @IBOutlet weak var mainView: UIView!
        @IBOutlet weak var image: UIImageView!
        @IBOutlet weak var titleLabel: UILabel!
        @IBOutlet weak var subTitleLable: UILabel!
        @IBOutlet weak var donatonButton: UIButton!
        @IBOutlet weak var nextButton: UIButton!
      

        //====================================================
        // MARK: - Properties
        //====================================================

        weak var delegate: DonatedAlertDelegate?
    //    var dedicationText: String = ""
    //    var dedicationNameText: String = ""
    //    var nameText: String = ""
    //    var locationText: String = ""

        //====================================================
        // MARK: - Life Cycle
        //====================================================

        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return [.portrait]
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            self.setStrings()
            self.setCornerRadius()
            self.setShadow()
            self.roundButtonSetup()
        }

        override func loadView() {
            Bundle.main.loadNibNamed("NotDonationAlert", owner: self, options: nil)
        }

        //====================================================
        // MARK: - Setup
        //====================================================
        func setStrings() {
            self.titleLabel.text = Strings.theKetarimBank
            self.subTitleLable.text = Strings.itIsEmpty
            self.donatonButton.setTitle(Strings.donatedBtn, for: .normal)
            self.nextButton.setTitle(Strings.donateKetarim, for: .normal)
        }

        func setCornerRadius() {
            self.mainView.layer.cornerRadius = 31
            self.donatonButton.layer.cornerRadius = 18
            self.nextButton.layer.cornerRadius = 18

        }

        func setShadow() {
            let shadowOffset = CGSize(width: 0.0, height: 20)
            let color = #colorLiteral(red: 0.16, green: 0.17, blue: 0.39, alpha: 0.5)
            Utils.dropViewShadow(view: self.mainView, shadowColor: color, shadowRadius: 31, shadowOffset: shadowOffset)
        }

       func roundButtonSetup (){
    //        Utils.setViewShape(
    //            view: buttonShadow,
    //            viewBorderWidht: 20,
    //            viewBorderColor: self.mode ? UIColor.turquoise36: UIColor.warmPink35,
    //            viewCornerRadius: buttonShadow.bounds.width / 2)
    //        button.layer.cornerRadius = button.bounds.width / 2
    //
    //        Utils.setViewShape(
    //            view: buttonCenter,
    //            viewBorderWidht: 10,
    //            viewBorderColor: self.mode ? UIColor.turquoise: UIColor.blushPink,
    //            viewCornerRadius: button.bounds.width / 2)
    //        buttonCenter.backgroundColor = self.mode ? UIColor.ttueal: UIColor.fadedRed
            
        } //====================================================
        // MARK: - @IBActions
        //====================================================


        @IBAction func startLessonButtonPresed(_ sender: Any) {
            self.dismiss(animated: true) {
            self.delegate?.didDismiss()
            }
            
        }
        
        @IBAction func donatonButtonPressed(_ sender: Any) {
            
        }
       

}
