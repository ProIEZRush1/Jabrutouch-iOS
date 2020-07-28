//
//  WelcomeDonationViewController.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 26/07/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class WelcomeDonationViewController: UIViewController {
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
        welcomeTitle.text = "\(userName),"
        goTourButton.layer.cornerRadius = 15
    }
    
    //============================================================
    // MARK: - Navigation
    //============================================================
    
    
    @IBAction func goTourButtonPressed(_ sender: Any) {
        navigateToDonationWalkThrough()
        self.sendStatus(viewed: true)
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        navigateToMain()
        self.sendStatus(viewed: false)
    }
    
    func sendStatus(viewed: Bool){
        guard let token = UserDefaultsProvider.shared.currentUser?.token else { return }
        guard let userId = UserDefaultsProvider.shared.currentUser?.id else { return }
        API.setUserTour(authToken: token, tourNum: 1, user: userId, viewed: viewed, completionHandler:())
            
    }
    //============================================================
    // MARK: - Navigation
    //============================================================
    
    private func navigateToMain() {
        let mainViewController = Storyboards.Main.mainViewController
        appDelegate.setRootViewController(viewController: mainViewController, animated: true)
    }
    
    private func navigateToDonationWalkThrough() {
        let donationsWalkThroughViewController = Storyboards.DonationWalkThrough.donationsWalkThroughViewController
        appDelegate.setRootViewController(viewController: donationsWalkThroughViewController, animated: true)
    }
    
}

