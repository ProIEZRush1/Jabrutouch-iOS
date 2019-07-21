//בעזרת ה׳ החונן לאדם דעת
//  ModalsContainerViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 22/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class ModalsContainerViewController: UIViewController {

    weak var delegate: MainModalDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentDownloads" {
            let vc = segue.destination as? DownloadsNavigationController
            vc?.modalDelegate = self.delegate
        }
    }
 

}
