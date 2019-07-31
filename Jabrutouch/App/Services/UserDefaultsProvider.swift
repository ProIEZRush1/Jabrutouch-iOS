//בעזרת ה׳ החונן לאדם דעת
//  UserDefaultsProvider.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 31/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class UserDefaultsProvider {
    
    private enum UserDefaultsKeys: String {
        case currentUsername = "CurrentUsername"
        case currentPassword = "CurrentPassword"
        case currentUser = "CurrentUser"
    }
    
    static private var provider: UserDefaultsProvider?
    
    private let defaults = UserDefaults.standard
    
    private init() {
        
    }
    
    class var shared: UserDefaultsProvider {
        if self.provider == nil {
            self.provider = UserDefaultsProvider()
        }
        return self.provider!
    }
    
    var currentUsername: String? {
        get {
            return self.defaults.string(forKey: UserDefaultsKeys.currentUsername.rawValue)
        }
        set (username){
            self.defaults.set(username, forKey: UserDefaultsKeys.currentUsername.rawValue)
            self.defaults.synchronize()
        }
    }
    
    var currentPassword: String? {
        get {
            return self.defaults.string(forKey: UserDefaultsKeys.currentPassword.rawValue)
        }
        set (username){
            self.defaults.set(username, forKey: UserDefaultsKeys.currentPassword.rawValue)
            self.defaults.synchronize()
        }
    }
    
    var currentUser: JTUser? {
        get {
            guard let values = self.defaults.object(forKey: UserDefaultsKeys.currentUser.rawValue) as? [String:Any] else { return nil }
            return JTUser(values: values)
            
        }
        set (user){
            self.defaults.set(user?.values, forKey: UserDefaultsKeys.currentUser.rawValue)
            self.defaults.synchronize()
        }
    }
}
