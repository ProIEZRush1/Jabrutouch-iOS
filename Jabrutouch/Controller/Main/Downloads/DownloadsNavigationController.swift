//בעזרת ה׳ החונן לאדם דעת
//  DownloadsNavigationController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 22/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class DownloadsNavigationController: UINavigationController {

    weak var modalDelegate: MainModalDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let downloadsViewController = self.children.first as? DownloadsViewController {
            //downloadsViewController.delegate = self.modalDelegate // Marked by Aaron Tuil because it prevented the app to run
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
