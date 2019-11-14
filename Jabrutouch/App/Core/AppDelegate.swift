//
//  AppDelegate.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import AWSS3

let appDelegate = UIApplication.shared.delegate as! AppDelegate
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var topmostViewController: UIViewController? {
        guard let window = self.window else { return nil }
        guard var viewController = window.rootViewController else { return nil }
        while viewController.children.first != nil || viewController.presentedViewController != nil {
            if viewController.children.first != nil {
                viewController = viewController.children.first!
            }
            else if viewController.presentedViewController != nil {
                viewController = viewController.presentedViewController!
            }
            
        }
        return viewController
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Fabric.with([Crashlytics.self])
        print(UserDefaultsProvider.shared.currentUser?.token ?? "")
        print((UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]).first!)
        // Initialize
        _ = ContentRepository.shared
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        AWSS3TransferUtility.interceptApplication(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    }
    
    func setRootViewController(viewController: UIViewController, animated: Bool) {
        if self.window == nil {
            self.window = UIWindow()
        }
        let window = self.window!
        if animated {
            UIView.transition(with: window, duration: 0.3, options: [.transitionCrossDissolve], animations: {
                window.rootViewController = viewController
            }) { (Bool) in
                window.makeKeyAndVisible()
            }
        }
        else {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }
}

