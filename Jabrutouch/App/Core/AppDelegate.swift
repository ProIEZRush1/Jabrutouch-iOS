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
//        _ = MessagesRepository.shared
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
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    

}


extension AppDelegate:UNUserNotificationCenterDelegate {
    
    func centerNotificationManager(){
        notificatioCenter.getDeliveredNotifications { (notifications:[UNNotification]) in
            for n in notifications{
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
        if let key = userInfo["data"] as? String, let values = self.convertToJson(text: key){
            if let message = JTMessage(values: values){
                MessagesRepository.shared.saveMessageInDB(message: message)
            }
        }
        print("Received: \(userInfo)")
        completionHandler(.newData)
    }
    
  
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
       
        if let key = userInfo["data"] as? String, let values = self.convertToJson(text: key){
            if let message = JTMessage(values: values){
                MessagesRepository.shared.saveMessageInDB(message: message)
            }
        }
        print("willPresent: ")

        completionHandler([.alert, .sound])
    }
    
    func convertToJson(text: String) -> [String: Any]? {
            if let data = text.data(using: .utf8) {
                do {
                    return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                } catch {
                    print(error.localizedDescription)
                }
            }
            return nil
    }
//
//    private func sendUserNotification(body: String, userInfo: [AnyHashable:Any]) {
//        let content = UNMutableNotificationContent()
//        content.body = body
//        content.userInfo = userInfo
//
//        let request = UNNotificationRequest(identifier: "", content: content, trigger: nil)
//        UNUserNotificationCenter.current().add(request) { (error:Error?) in
//            if let error = error {
//                print("Failed adding notification request, with error: \(error)")
//            }
//        }
//    }
   
}
