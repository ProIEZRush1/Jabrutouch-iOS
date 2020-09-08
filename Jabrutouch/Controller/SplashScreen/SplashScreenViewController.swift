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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
        ContentRepository.shared.removeOldDownloadedFiles()
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.failedLoadingShas(_:)), name: .failedLoadingShas, object: nil)
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
        DispatchQueue.global().async{
            // if internet connection available
            if appDelegate.isInternetConenect {
                do {
                    let isLastVersion = try self.isUpdateAvailable()
                    if !isLastVersion {
                        DispatchQueue.main.async {
                            self.newVersionAlert()
                        }
                    } else {
                        
                        LoginManager.shared.signIn(phoneNumber: phoneNumber, email: email, password: password) { (result) in
                            DispatchQueue.main.async {
                                switch result {
                                case .success:
                                    
                                    let showTour = UserDefaultsProvider.shared.currentUser?.showTour
                                    switch showTour {
                                    case 0:
                                        self.navigateToMain()
                                    case 1:
                                        self.navigateToDonationTourWalkThrough()
                                    case 2:
                                        self.navigateToDonationPopUp()
                                    case 3:
                                        self.navigateToLastDonationPopUp()
                                    default:
                                        self.navigateToMain()
                                    }
                                    
                                case .failure(let error):
                                    print(error)
                                    //                    self.navigateToMain()
                                    self.navigateToSignIn()
                                }
                            }
                        }
                    }
                } catch {
                    
                }
            } else {
                // if internet connection not available
                if UserDefaultsProvider.shared.currentUser?.token != nil {
                    self.navigateToMain()
                }else {
                    self.navigateToSignIn()
                }
            }
        }
    }
    
    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
    
    
    
    func isUpdateAvailable() throws -> Bool {
        var isLastVersion = true
        let semaphore = DispatchSemaphore(value: 0)
        
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String else {
                throw VersionError.invalidBundleInfo
        }
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            throw JTError.authTokenMissing
        }
        
        let version = currentVersion.split(separator: ".")
        let versionInt = Int(version.joined(separator: ""))
        
        API.getLastAppVersion(authToken: authToken, currentAppVersion: versionInt ?? 0, completionHandler: {(result:APIResult<JTAppVersion>)in
            switch result {
            case .success(let result):
                isLastVersion = result.lastVersion
            case .failure(let error):
                print("Error: ", error.message)
            }
            semaphore.signal()
        })
        _ = semaphore.wait(wallTimeout: .distantFuture)
        return isLastVersion
    }
    
    
    func userModeSelector(){
        
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
    
    private func navigateToWelcomeTour() {
        let welcomeTourViewController = Storyboards.TourWalkThrough.welcomeTourViewController
        appDelegate.setRootViewController(viewController: welcomeTourViewController, animated: true)
    }
    
    private func navigateToDonationTourWalkThrough() {
        let donationsWalkThroughViewController = Storyboards.DonationWalkThrough.welcomeDonationViewController
        appDelegate.setRootViewController(viewController: donationsWalkThroughViewController, animated: true)
    }
    
    private func navigateToDonationPopUp() {
        let mainViewController = Storyboards.Main.mainViewController
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true, completion: nil)
        mainViewController.presentDonationPopUp()
    }
    
    private func navigateToLastDonationPopUp() {
        let mainViewController = Storyboards.Main.mainViewController
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true, completion: nil)
        mainViewController.presentLastDonationPopUp()
    }
    
    private func navigateToMain() {
        let mainViewController = Storyboards.Main.mainViewController
        appDelegate.setRootViewController(viewController: mainViewController, animated: true)
    }
    
    private func newVersionAlert() {
        let mainViewController = Storyboards.Main.mainViewController
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true, completion: nil)
        mainViewController.presentNewVersionAlert()
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
    
    @objc func failedLoadingShas(_ notification: Notification) {
        if UserDefaultsProvider.shared.seenWalkThrough == false {
            self.navigateToWalkThrough()
            return
        }
        if let username = UserDefaultsProvider.shared.currentUsername, let password = UserDefaultsProvider.shared.currentPassword {
            self.attemptSignIn(username: username, password: password)
        }
        else {
            self.navigateToSignIn()
        }
    }
}
