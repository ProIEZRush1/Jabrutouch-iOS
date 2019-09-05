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
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var location: UILabel!
    
    weak var delegate: DonatedAlertDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStrings()
        self.setCornerRadius()
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        Bundle.main.loadNibNamed("DonatedAlert", owner: self, options: nil)
    }

    func setStrings() {
        self.titleLabel.text = Strings.donatedTitle
        self.startBtn.setTitle(Strings.donatedBtn, for: .normal)
    }

    func setCornerRadius() {
        self.mainView.layer.cornerRadius = 31
        self.startBtn.layer.cornerRadius = 18
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.didDismiss()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
