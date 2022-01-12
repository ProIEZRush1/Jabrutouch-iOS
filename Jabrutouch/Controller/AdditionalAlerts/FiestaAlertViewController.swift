//
//  FiestaAlertViewController.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 20/08/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class FiestaAlertViewController: UIViewController {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup(){
        alertView.layer.cornerRadius = 15
        alertView.clipsToBounds = true
        button.layer.cornerRadius = 15
        cancelButton.layer.cornerRadius = 4
    }
    
    @IBAction func cancel(_ sender: Any) {
        UserDefaultsProvider.shared.fiestaPopUpDetail = JTFiestaPopup(currentDate:Date())
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        if let authToken = UserDefaultsProvider.shared.currentUser?.token{
            API.postCampaignMail(token: authToken){(response: APIResult<PostCampingMailResponse>) in
                switch response {
                case .success:
                    print("SUCCESS")
                    var fiestaPopUpDetail = JTFiestaPopup(currentDate:Date())
                    fiestaPopUpDetail?.agree = true
                    UserDefaultsProvider.shared.fiestaPopUpDetail = fiestaPopUpDetail
                case .failure(let error):
                    print("Error: ", error.message)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2, execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
}
