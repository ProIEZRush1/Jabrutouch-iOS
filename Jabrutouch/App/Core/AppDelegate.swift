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
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if let host = url.host {
            let mainViewController = Storyboards.Main.mainViewController
            mainViewController.modalPresentationStyle = .fullScreen
            
            if host == "crowns" {
                self.topmostViewController?.present(mainViewController, animated: false, completion: nil)
                mainViewController.presentOldDonations()
            } else if host == "download" {
                self.topmostViewController?.present(mainViewController, animated: false, completion: nil)
                mainViewController.presentDownloadsViewController()
            } else if host == "gemara" {
                self.topmostViewController?.present(mainViewController, animated: false, completion: nil)
                mainViewController.presentAllGemara()
            } else if host == "mishna" {
                self.topmostViewController?.present(mainViewController, animated: false, completion: nil)
                mainViewController.presentAllMishna()
            }
            
        }
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
    
    //=====================================================
    // MARK: - Core Data stack
    //=====================================================
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "il.co.Ravtech.FieldBit" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "DataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("jabroutouch.sqlite")
        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: mOptions)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error!), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
}


extension AppDelegate:UNUserNotificationCenterDelegate {
    
    func centerNotificationManager(){
        notificatioCenter.getDeliveredNotifications { (notifications:[UNNotification]) in
            for notification in notifications{
                let userInfo = notification.request.content.userInfo
                self.saveNewNotificationInDB(userInfo){ (chatId) in}
            }
        }
        
        notificatioCenter.getPendingNotificationRequests{ (notifications:[UNNotificationRequest]) in
            for n in notifications{
                print(n,"getPendingNotificationRequests")
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if application.applicationState == .background || application.applicationState == .inactive{
            saveNewNotificationInDB(userInfo) {(chatId) in
                let navigationVC = Storyboards.Messages.messagesNavigationController
                navigationVC.modalPresentationStyle = .fullScreen
                self.topmostViewController?.present(navigationVC, animated: false, completion: nil)
                if let messageVC = navigationVC.children.first as? MessagesViewController{
                    messageVC.presentChat(chatId)
                }
            }
        }else{
            if let key = userInfo["data"] as? String, let values = self.convertToJson(text: key){
                if let message = JTMessage(values: values) {
                    let navigationVC = Storyboards.Messages.messagesNavigationController
                    navigationVC.modalPresentationStyle = .fullScreen
                    self.topmostViewController?.present(navigationVC, animated: false, completion: nil)
                    if let messageVC = navigationVC.children.first as? MessagesViewController{
                        messageVC.presentChat(message.chatId)
                    }
                }
            }
        }
        completionHandler(.newData)
    }
    
  
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        saveNewNotificationInDB(userInfo) { (chatId) in
//            if self.topmostViewController is MessagesViewController {
//                let  ChatViewController = ChatViewController.self.getChatId()
//                let displayChatId = controller.currentChat?.chatId
//                if displayChatId == chatId{
//                    return
//                }
//            }
            completionHandler([.alert, .sound])
        }
    }
    
    func saveNewNotificationInDB(_ userInfo: [AnyHashable : Any], completion: @escaping (_ chatId: Int)->Void) {
        if let key = userInfo["data"] as? String, let values = self.convertToJson(text: key){
            if let message = JTMessage(values: values) {
                if message.messageType == 1 {
                    MessagesRepository.shared.saveMessageInDB(message: message)
                    completion(message.chatId)
                    return
                }
                else if message.messageType == 2 {
                    AWSS3Provider.shared.handleFileDownload(fileName: "users-record/\(message.message)", bucketName: AWSS3Provider.appS3BucketName, progressBlock: nil) {  (result) in
                        switch result{
                        case .success(let data):
                            do{
                                try
                                    FilesManagementProvider.shared.overwriteFile(
                                        path: FilesManagementProvider.shared.loadFile(link: "\(message.message)",
                                            directory: FileDirectory.recorders),
                                        data: data)
                                MessagesRepository.shared.saveMessageInDB(message: message)
                                completion(message.chatId)
                            } catch {
                                print("error")
                            }
                            
                        case .failure(let error):
                            print(error)
                            break
                        }
                    }
                }
            }
        }
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
   
    
}
