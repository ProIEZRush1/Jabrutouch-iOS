//
//  UserRepository.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 20/11/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class UserRepository {
    
    private static var userRepo: UserRepository?
    
    private var currentUser: JTUser?
    
    private init() {
        self.currentUser = UserDefaultsProvider.shared.currentUser
    }
    
    class var shared: UserRepository {
        if self.userRepo == nil {
            self.userRepo = UserRepository()
        }
        return self.userRepo!
    }
    
    func getCurrentUser() -> JTUser? {
        return self.currentUser
    }
    
    func setCurrentUser(_ user: JTUser, password: String) {
        self.currentUser = user
        UserDefaultsProvider.shared.currentUsername = user.email
        UserDefaultsProvider.shared.currentPassword = password
        UserDefaultsProvider.shared.currentUser = user
        if user.lessonDonated?.donated == true {
            UserDefaultsProvider.shared.donationPending = false
        }
    }
    
    func setProfileImage(image: UIImage?) {
        self.currentUser?.profileImage = image
    }
    
    func updateCurrentUser(_ user: JTUser) {
        self.currentUser = user
        UserDefaultsProvider.shared.currentUser = user
    }
    
    func clearCurrentUser() {
        self.currentUser = nil
        UserDefaultsProvider.shared.currentUsername = nil
        UserDefaultsProvider.shared.currentPassword = nil
        UserDefaultsProvider.shared.currentUser = nil
        UserDefaultsProvider.shared.lessonWatched = []
        UserDefaultsProvider.shared.videoWatched = false
        UserDefaultsProvider.shared.donationPending = false
    }
}
