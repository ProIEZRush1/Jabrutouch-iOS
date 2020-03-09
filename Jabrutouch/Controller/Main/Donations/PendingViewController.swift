//
//  PendingViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 09/03/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class PendingViewController: UIViewController {

    @IBOutlet weak var yourDonationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setText()
    }
    
    private func setText() {
        self.yourDonationLabel.text = Strings.yourDonation
        self.titleLabel.text = Strings.youHaveNotDonateYet
        self.subTitleLabel.text = Strings.joinOthers
    }
}
