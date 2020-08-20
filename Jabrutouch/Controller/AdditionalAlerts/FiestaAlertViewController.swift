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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        button.titleLabel?.text = "I agreed to receive an email."
        button.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 4, execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
}
