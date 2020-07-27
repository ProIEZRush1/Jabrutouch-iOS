//
//  DonationLastPopUpViewController.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 27/07/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class DonationLastPopUpViewController: UIViewController {
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var buttonBox: UIView!
    @IBOutlet weak var bottunTitle: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    func setup(){
        alertView.layer.cornerRadius = 15
        buttonBox.layer.cornerRadius = 15
        bottunTitle.text = Strings.donationPopUpButton4
        let sentence = "\(UserDefaultsProvider.shared.currentUser?.firstName ?? "" )\(Strings.donationPopUpBody4)"
        let regularAttributes = [NSAttributedString.Key.font: Fonts.regularFont(size: 20)]
        let largeAttributes = [NSAttributedString.Key.font: Fonts.mediumTextFont(size: 20), NSAttributedString.Key.foregroundColor: Colors.appBlue]
        let attributedSentence = NSMutableAttributedString(string: sentence, attributes: regularAttributes)

        attributedSentence.setAttributes(regularAttributes, range: NSRange(location: 0, length: sentence.count-23))
        attributedSentence.setAttributes(largeAttributes, range: NSRange(location: sentence.count-23, length: 15))
        bottunTitle.attributedText = attributedSentence
    }
    @IBAction func buttonPressed(_ sender: Any) {
        let mainViewController = Storyboards.Main.mainViewController
                   mainViewController.modalPresentationStyle = .fullScreen
                   self.present(mainViewController, animated: false, completion: nil)
                   mainViewController.presentDonation()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
}
