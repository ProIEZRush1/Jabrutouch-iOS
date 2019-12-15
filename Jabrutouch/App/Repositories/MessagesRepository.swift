//
//  MessagesRepository.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 10/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation
import Firebase
import FirebaseMessaging

class MessagesRepository: NSObject, MessagingDelegate {
    
    var fcmToken = ""
    static private var manager: MessagesRepository?
    
    class var shared: MessagesRepository {
        if self.manager == nil {
            self.manager = MessagesRepository()
        }
        return self.manager!
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("fcmToken: \(fcmToken)")
        self.fcmToken = fcmToken
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
    }
    
    
}
