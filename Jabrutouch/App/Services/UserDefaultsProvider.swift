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
        case seenWalkThrough = "SeenWalkThrough"
        case notFirstTime = "notFirstTime"
        case appLanguages = "AppleLanguages"
        case index = "Index"
        case lessonWatched = "LessonWatched"
        case videoWatched = "VideoWatched"
    }
    
    static private var provider: UserDefaultsProvider?
    
    private let defaults = UserDefaults.standard
    
    private init() {
        self.defaults.register(defaults: [
            UserDefaultsKeys.seenWalkThrough.rawValue: false,
            UserDefaultsKeys.appLanguages.rawValue: ["es"]
            ]
        )
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
    
    var seenWalkThrough: Bool {
        get {
            return self.defaults.bool(forKey: UserDefaultsKeys.seenWalkThrough.rawValue)
            
        }
        set (value){
            self.defaults.set(value, forKey: UserDefaultsKeys.seenWalkThrough.rawValue)
            self.defaults.synchronize()
        }
    }
    
    var notFirstTime: Bool {
        get {
            return self.defaults.bool(forKey: UserDefaultsKeys.notFirstTime.rawValue)
        }
        set (value) {
            self.defaults.set(value, forKey: UserDefaultsKeys.notFirstTime.rawValue)
            self.defaults.synchronize()
        }
    }
    
    var appLanguageCode: String {
        get {
            return (self.defaults.object(forKey: UserDefaultsKeys.appLanguages.rawValue) as! [String]).first!
        }
        set (languageCode) {
            self.defaults.set([languageCode], forKey: UserDefaultsKeys.appLanguages.rawValue)
            self.defaults.synchronize()
        }
    }
    var index: Int {
        get {
            return self.defaults.integer(forKey: UserDefaultsKeys.index.rawValue)
        }
        set (index) {
            self.defaults.set(index, forKey: UserDefaultsKeys.index.rawValue)
            self.defaults.synchronize()
        }
    }
    
    var lessonWatched: [JTLessonWatched] {
        get {
            guard let values = self.defaults.object(forKey: UserDefaultsKeys.lessonWatched.rawValue) as? [[String:Any]] else { return []}
            return values.compactMap{JTLessonWatched(values: $0)}
        }
        set (lessonWatched) {
            self.defaults.set(lessonWatched.map{$0.values}, forKey: UserDefaultsKeys.lessonWatched.rawValue)
            self.defaults.synchronize()
        }
    }
    
    var videoWatched: Bool {
        get {
            return self.defaults.bool(forKey: UserDefaultsKeys.videoWatched.rawValue)
        }
        set (value) {
            self.defaults.set(value, forKey: UserDefaultsKeys.videoWatched.rawValue)
            self.defaults.synchronize()
        }
    }
}
