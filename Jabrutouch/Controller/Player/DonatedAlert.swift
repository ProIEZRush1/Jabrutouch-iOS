//
//  DonatedAlert.swift
//  Jabrutouch
//
//  Created by yacov sofer on 05/09/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

protocol DonatedAlertDelegate: class {
    func didDismiss()
}

class DonatedAlert: UIViewController {
    
    //====================================================
    // MARK: - @IBOutlets
    //====================================================
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var location: UILabel!
    
    //====================================================
    // MARK: - Properties
    //====================================================
    
    weak var delegate: DonatedAlertDelegate?
    
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
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        Bundle.main.loadNibNamed("DonatedAlert", owner: self, options: nil)
    }

    //====================================================
    // MARK: - Setup
    //====================================================
    func setStrings() {
        self.titleLabel.text = Strings.donatedTitle
        self.startBtn.setTitle(Strings.donatedBtn, for: .normal)
    }

    func setCornerRadius() {
        self.mainView.layer.cornerRadius = 31
        self.startBtn.layer.cornerRadius = 18
        
    }
    
    func setShadow() {
        let shadowOffset = CGSize(width: 0.0, height: 20)
        let color = #colorLiteral(red: 0.16, green: 0.17, blue: 0.39, alpha: 0.5)
        Utils.dropViewShadow(view: self.mainView, shadowColor: color, shadowRadius: 31, shadowOffset: shadowOffset)
    }
    
    //====================================================
    // MARK: - @IBActions
    //====================================================
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.didDismiss()
        }
    }

}
