//
//  PopUpViewController.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 10/06/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
    
    weak var delegate: MainModalDelegate?
    
    
    
    @IBOutlet weak var popupButton: UIButton!
    @IBOutlet weak var first: UIView!
    @IBOutlet weak var second: UIView!
    @IBOutlet weak var third: UIView!
    @IBOutlet weak var fourth: UIView!
    @IBOutlet weak var fifth: UIView!
    
    var currentPopup: JTPopup?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentPopup()
        setup()
    }
    // ===============
    // MARK:  - setup
    // ===============
    
    func setup(){
        self.popupButton.layer.cornerRadius = 10
    }
    
    
    func presentPopup(){
        print(currentPopup?.type ?? "")
        first.isHidden = true
        second.isHidden = true
        third.isHidden = true
        fourth.isHidden = true
        fifth.isHidden = true
        switch self.currentPopup?.type {
        case 1:
            first.isHidden = false
        case 2:
            second.isHidden = false
        case 3:
            third.isHidden = false
        case 4:
            fourth.isHidden = false
        case 5:
            fifth.isHidden = false
        default:
            return
        }
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func gotItButtonPressed(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "firstChild" {
            if let firstChildCV = segue.destination as? FirstChildVC {
                firstChildCV.currentPopup = self.currentPopup
            }
        }else if segue.identifier == "secondChild" {
            if let secondChildCV = segue.destination as? SecondChildVC {
                secondChildCV.currentPopup = self.currentPopup
            }
        }else if segue.identifier == "thirdChild" {
            if let secondChildCV = segue.destination as? ThirdChildVC {
                secondChildCV.currentPopup = self.currentPopup
            }
        }else if segue.identifier == "forthChild" {
            if let secondChildCV = segue.destination as? FourthChildVC {
                secondChildCV.currentPopup = self.currentPopup
            }
        }else if segue.identifier == "fifthChild" {
            if let secondChildCV = segue.destination as? FifthChildVC {
                secondChildCV.currentPopup = self.currentPopup
            }
        }
    }
    
}
