//בעזרת ה׳ החונן לאדם דעת
//  MainTabBarController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setItemTitles()
    }

    private func setItemTitles() {
        self.tabBar.items?[0].title = Strings.main
        self.tabBar.items?[1].title = Strings.downloads
        self.tabBar.items?[2].title = Strings.gemara
        self.tabBar.items?[3].title = Strings.mishna
        self.tabBar.items?[4].title = Strings.donations
    }

}

