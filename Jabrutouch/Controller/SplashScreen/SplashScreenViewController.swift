//בעזרת ה׳ החונן לאדם דעת
//  SplashScreenViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 04/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    //========================================
    // MARK: - @OBOutlets
    //========================================
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    //========================================
    // MARK: - Notifications setup
    //========================================
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.shasLoaded(_:)), name: .shasLoaded, object: nil)
    }
    
    private func attemptSignIn(username: String, password: String) {
        var phoneNumber: String?
        var email: String?
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        if Utils.validateEmail(username) {
            email = username
        }
        else if Utils.validatePhoneNumber(username) {
            phoneNumber = username
        }
        else {
            self.navigateToSignIn()
        }
        
        LoginManager.shared.signIn(phoneNumber: phoneNumber, email: email, password: password) { (result) in
            switch result {
            case .success:
                self.navigateToMain()
            case .failure(let error):
                print(error)
                self.navigateToSignIn()
            }
        }
    }
    // MARK: - Navigation

    private func navigateToSignIn() {
        let signInViewController = Storyboards.SignIn.signInViewController
        appDelegate.setRootViewController(viewController: signInViewController, animated: true)

    }
    
    private func navigateToWalkThrough() {
        let walkThroughViewController = Storyboards.WalkThrough.walkThroughViewController
        appDelegate.setRootViewController(viewController: walkThroughViewController, animated: true)
    }
    
    private func navigateToMain() {
        let mainViewController = Storyboards.Main.mainViewController
        appDelegate.setRootViewController(viewController: mainViewController, animated: true)

    }

    //========================================
    // MARK: - Notification observations
    //========================================
    
    @objc func shasLoaded(_ notifcation: Notification) {
        if UserDefaultsProvider.shared.seenWalkThrough == false {
            self.navigateToWalkThrough()
        }
        else if let username = UserDefaultsProvider.shared.currentUsername, let password = UserDefaultsProvider.shared.currentPassword {
            self.attemptSignIn(username: username, password: password)
        }
        else {
            self.navigateToSignIn()
        }
    }
}
