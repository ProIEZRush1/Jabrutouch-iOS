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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup(){
        alertView.layer.cornerRadius = 15
        button.layer.cornerRadius = 15
    }
    
    @IBAction func cancel(_ sender: Any) {
        UserDefaultsProvider.shared.fiestaPopUpDetail = JTFiestaPopup(currentDate:Date())
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        var fiestaPopUpDetail = JTFiestaPopup(currentDate:Date())
        fiestaPopUpDetail?.agree = true
        UserDefaultsProvider.shared.fiestaPopUpDetail = fiestaPopUpDetail
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 4, execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
}
