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
import Firebase
import FirebaseMessaging

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let notificatioCenter = UNUserNotificationCenter.current()

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
        FirebaseApp.configure()
        registerForPushNotifications(application: application)
        Messaging.messaging().delegate = MessagesRepository.shared
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map{ String(format: "%02.2hhx", $0) }.joined()
        print("Notifications token: " + token)
//        fcmToken = token

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
    
    func registerForRemoteNotifications(application: UIApplication) {
        let options:UNAuthorizationOptions = [.alert,.badge,.sound,.carPlay]
        notificatioCenter.requestAuthorization(options: options, completionHandler: { (granted:Bool, error: Error?) in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                    let categories: Set<UNNotificationCategory> = []
                    notificatioCenter.setNotificationCategories(categories)
                }
            }
        })
    }
    
    func registerForPushNotifications(application:UIApplication) {

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
        }
        notificatioCenter.delegate = self
        self.registerForRemoteNotifications(application: application)
        centerNotificationManager()
    }
    
    func setRootViewController(viewController: UIViewController, animated: Bool) {
        if self.window == nil {
            self.window = UIWindow()
        }
        let window = self.window!
        DispatchQueue.main.async {
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
}

    
extension AppDelegate:UNUserNotificationCenterDelegate{
    
    func centerNotificationManager(){
        notificatioCenter.getDeliveredNotifications { (notifications:[UNNotification]) in
            for n in notifications{
//                let userInfo = n.request.content.userInfo
//                //print("## userInfo ## \(userInfo.debugDescription)")
//                let remoteNotification = userInfo as! [String: AnyObject]
                //print("## remoteNotification ## \(remoteNotification.debugDescription)")
//                self.queue.sync {
//
//                    let _ = self.parsFCMNotification(messageInfo: n)
//                }

                print(n,"getDeliveredNotifications")
            }
        }
        
        notificatioCenter.getPendingNotificationRequests{ (notifications:[UNNotificationRequest]) in
            for n in notifications{
                print(n,"getPendingNotificationRequests")
            }
        }
    }
   
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
