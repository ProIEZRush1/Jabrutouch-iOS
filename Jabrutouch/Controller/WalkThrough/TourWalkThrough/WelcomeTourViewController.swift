//
//  WelcomTourViewController.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 23/07/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class WelcomeTourViewController: UIViewController {
    @IBOutlet weak var welcomeTitle: UILabel!
    @IBOutlet weak var goTourButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    func setup(){
        var userName = ""
        if let name = UserDefaultsProvider.shared.currentUser?.firstName { userName = name
        }
        welcomeTitle.text = "Bienvenido \(userName)"
        goTourButton.layer.cornerRadius = 15
    }
    
    //============================================================
    // MARK: - Navigation
    //============================================================
    
    
    @IBAction func goTourButtonPressed(_ sender: Any) {
        navigateToTourWalkThrough()
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        navigateToMain()
    }
    //============================================================
    // MARK: - Navigation
    //============================================================
    
    private func navigateToMain() {
        let mainViewController = Storyboards.Main.mainViewController
        appDelegate.setRootViewController(viewController: mainViewController, animated: true)
    }
    
    private func navigateToTourWalkThrough() {
        let tourWalkThroughViewController = Storyboards.TourWalkThrough.tourWalkThroughViewController
        appDelegate.setRootViewController(viewController: tourWalkThroughViewController, animated: true)
    }
    
}
