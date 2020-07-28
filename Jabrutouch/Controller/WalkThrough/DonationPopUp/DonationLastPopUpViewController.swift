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
    @IBOutlet weak var text2: UILabel!
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
        
        let sentence = "Estimado \(UserDefaultsProvider.shared.currentUser?.firstName ?? "" ), \n\(Strings.donationPopUpBody4)"
        text.text = sentence
        text2.text = Strings.donationPopUpbody4_1
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        sendStatus(viewed: true)
        let mainViewController = Storyboards.Main.mainViewController
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: false, completion: nil)
        mainViewController.presentDonation()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        sendStatus(viewed: false)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func sendStatus(viewed: Bool){
        guard let token = UserDefaultsProvider.shared.currentUser?.token else { return }
        guard let userId = UserDefaultsProvider.shared.currentUser?.id else { return }
        API.setUserTour(authToken: token, tourNum: 3, user: userId, viewed: viewed, completionHandler:())
        
    }
    
}
