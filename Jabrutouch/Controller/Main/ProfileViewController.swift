//בס״ד
//  ProfileViewController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 07/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    //========================================
    // MARK: - Properties
    //========================================
    
    var user: JTUser?
    var mainViewController: MainViewController?
    
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var logoutBtn: UIButton!
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = UserDefaultsProvider.shared.currentUser
        self.setStrings()
        self.roundCorners()
        self.setShadows()
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    private func setStrings() {
        self.nameLabel.text = user?.firstName ?? "" // + " " + user?.lastName ?? ""  // TODO Debug: XCode doesn't accept this expression
        self.emailLabel.text = user?.email
        self.phoneLabel.text = user?.phoneNumber // Debug: phone number is without two first numbers
    }
    
    private func roundCorners() {
        self.mainContentView.layer.cornerRadius = 15
        self.logoutBtn.layer.cornerRadius = 10
}
    
    private func setShadows() {
        let shadowOffset = CGSize(width: 0.0, height: 12)
        Utils.dropViewShadow(view: self.mainContentView, shadowColor: Colors.shadowColor, shadowRadius: 36, shadowOffset: shadowOffset)
    }
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        LoginManager.shared.signOut {
            DispatchQueue.main.async {
                self.mainViewController?.navigateToSignIn()
            }
        }
    }
}
