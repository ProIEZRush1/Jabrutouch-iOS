//בעזרת ה׳ החונן לאדם דעת
//  SplashScreenViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 04/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    private func attemptSignIn(username: String, password: String) {
        var phoneNumber: String?
        var email: String?
        
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
        signInViewController.modalTransitionStyle = .crossDissolve
        self.present(signInViewController, animated: true) {
            appDelegate.window?.rootViewController = signInViewController
            appDelegate.window?.makeKeyAndVisible()
        }
    }
    
    private func navigateToWalkThrough() {
        let walkThroughViewController = Storyboards.WalkThrough.walkThroughViewController
        walkThroughViewController.modalTransitionStyle = .crossDissolve
        self.present(walkThroughViewController, animated: true) {
            appDelegate.window?.rootViewController = walkThroughViewController
            appDelegate.window?.makeKeyAndVisible()
        }
    }
    
    private func navigateToMain() {
        let mainViewController = Storyboards.Main.mainViewController
        mainViewController.modalTransitionStyle = .crossDissolve
        self.present(mainViewController, animated: true) {
            appDelegate.window?.rootViewController = mainViewController
            appDelegate.window?.makeKeyAndVisible()
        }
    }

}
