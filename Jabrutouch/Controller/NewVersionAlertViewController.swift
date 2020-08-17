//
//  NewVersionAlertViewController.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 16/08/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class NewVersionAlertViewController: UIViewController {
    
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    
    func setup(){
        viewAlert.layer.cornerRadius = 15
        button.layer.cornerRadius = 15
    }
    @IBAction func buttonPressed(_ sender: Any) {
        let application = UIApplication.shared
        let appId = "1488439011"
        let appUrl = URL.init(string: "itms-apps://itunes.apple.com/us/app/Jabrutouch/id" + appId + "?mt=8")!
        if application.canOpenURL(appUrl) {
            application.open(appUrl, options: [.universalLinksOnly : false], completionHandler: nil)
        }
    }
}
