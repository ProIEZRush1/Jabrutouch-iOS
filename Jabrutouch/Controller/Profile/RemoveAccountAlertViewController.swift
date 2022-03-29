//
//  RemoveAccountAlertViewController.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 23/06/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class RemoveAccountAlertViewController: UIViewController {
    //========================================
        // MARK: - @IBOutlets and Fields
        //========================================
        
        @IBOutlet weak var titleLabel: UILabel!
        @IBOutlet weak var contentView: UIView!
        @IBOutlet weak var warningMsgLabel: UILabel!
        @IBOutlet weak var logoutButton: UIButton!
        @IBOutlet weak var cancelButton: UIButton!
        // TODO Add Outlets to custom alert with different texts
        
        weak var delegate: AlertViewDelegate?

        //========================================
        // MARK: - LifeCycle
        //========================================
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.titleLabel.text = Strings.areYouSure
            self.warningMsgLabel.text = Strings.removeAccountWarningMsg
            self.logoutButton.setTitle(Strings.removeAccount.uppercased(), for: .normal)
            self.cancelButton.setTitle(Strings.stayWithUs.uppercased(), for: .normal)

            self.setCorners()
        }
        
        //========================================
        // MARK: - Setup
        //========================================
        
        private func setCorners() {
            self.contentView.layer.cornerRadius = 31
            self.logoutButton.layer.cornerRadius = 18
            self.cancelButton.layer.cornerRadius = 18
        }
        
        //========================================
        // MARK: - @IBActions
        //========================================
        
        @IBAction func xButtonPressed(_ sender: Any) {
            dismiss(animated: true, completion: nil)
        }
        
        @IBAction func removeAccountPressed(_ sender: Any) {
            guard let token = UserDefaultsProvider.shared.currentUser?.token else { return }
            guard let userId = UserDefaultsProvider.shared.currentUser?.id else { return }
            API.removeAccount(authToken: token, userId: userId,  completionHandler: {_ in
                self.delegate?.okPressed()
                self.dismiss(animated: true, completion: nil)
            })
        }
        
        @IBAction func cancelPressed(_ sender: Any) {
            self.cancelButton.backgroundColor = #colorLiteral(red: 0.18, green: 0.17, blue: 0.66, alpha: 1)
            dismiss(animated: true, completion: nil)
        }
    }

    

    


