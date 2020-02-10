//בס"ד
//  AlertViewController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 08/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    
    //========================================
    // MARK: - @IBOutlets and Fields
    //========================================
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
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
        self.logoutButton.setTitle(Strings.logout, for: .normal)
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
    
    @IBAction func logoutPressed(_ sender: Any) {
        delegate?.okPressed()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.cancelButton.backgroundColor = #colorLiteral(red: 0.18, green: 0.17, blue: 0.66, alpha: 1)
        dismiss(animated: true, completion: nil)
    }
}

protocol AlertViewDelegate: class {
    func okPressed()
}
