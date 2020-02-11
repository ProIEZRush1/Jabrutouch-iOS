//בעזרת ה׳ החונן לאדם דעת
//  JTUser.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 29/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct JTUser {
    
    var id: Int
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var email: String
    var imageLink: String
    var birthdayString: String
    var country: String
    var community: JTCommunity?
    var religiousLevel: Int?
    var education: JTUserProfileParameter?
    var occupation: JTUserProfileParameter?
    var interest: [JTUserProfileParameter]
    var secondEmail: String
    var isPresenter: Bool
    var token: String
    var profileImage: UIImage?
    var lessonWatched: [JTLessonWatched] = []
    var lessonWatchCount: Int?
    var profilePercent: Int?
    var profileImageFileName: String {
        return "profile_image_\(self.id).jpeg"
    }
    
    var profileImageFileURL: URL? {
        return FileDirectory.cache.url?.appendingPathComponent(self.profileImageFileName)
    }
    
    var jsonFormattedBirthday: String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let _ = formatter.date(from: self.birthdayString) {
            return self.birthdayString
        }
        formatter.dateFormat = "dd/MM/yyyy"
        if let date = formatter.date(from: self.birthdayString) {
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        }
        return nil
    }
    init?(values: [String:Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let firstName = values["first_name"] as? String {
            self.firstName = firstName
        } else { return nil }
        
        if let lastName = values["last_name"] as? String {
            self.lastName = lastName
        } else { return nil }
        
        if let phoneNumber = values["phone"] as? String {
            self.phoneNumber = phoneNumber
        } else { return nil }
        
        if let email = values["email"] as? String {
            self.email = email
        } else { return nil }
        
        if let token = values["token"] as? String {
            self.token = token
        } else {
            guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
                return nil
            }
            self.token = authToken
        }
        
        if let communityValues = values["community"] as? [String:Any] {
            if let community = JTCommunity(values: communityValues) {
                self.community = community
            }
        }
        
        if let lessonWatchedValues = values["lessonWatched"] as? [[String:Any]] {
            self.lessonWatched = lessonWatchedValues.compactMap{JTLessonWatched(values: $0)}
        }
        
        if let lessonWatchCountValues = values["lesson_watch_count"] as? Int {
            self.lessonWatchCount = lessonWatchCountValues
        }
        
        self.imageLink = values["image"] as? String ?? ""
        self.birthdayString = values["birthday"] as? String ?? ""
        self.country = values["country"] as? String ?? ""
        self.religiousLevel = values["religious_level"] as? Int
        
        if let education = values["education"] as? [String: Any] {
            self.education = JTUserProfileParameter(data: education)
        }
        if let occupation = values["occupation"] as? [String: Any] {
            self.occupation = JTUserProfileParameter(data: occupation)
        }
        if let interest = values["interest"] as? [[String: Any]] {
            self.interest = interest.compactMap{ JTUserProfileParameter(data: $0) }
        } else {
            self.interest = []
        }
        self.secondEmail = values["second_email"] as? String ?? ""
        self.isPresenter = values["is_presenter"] as? Bool ?? false
        self.profilePercent = values["profile_percent"] as? Int
        self.loadProfileImageFromLocalFile()
    }
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["first_name"] = self.firstName
        values["last_name"] = self.lastName
        values["phone"] = self.phoneNumber
        values["email"] = self.email
        values["image"] = self.imageLink
        values["birthday"] = self.birthdayString
        values["country"] = self.country
        values["community"] = self.community?.values
        values["religious_level"] = self.religiousLevel
        values["education"] = self.education?.values
        values["occupation"] = self.occupation?.values
        values["interest"] = self.interest.map{$0.values}
        values["second_email"] = self.secondEmail
        values["is_presenter"] = self.isPresenter
        values["token"] = self.token
        values["lessonWatched"] = self.lessonWatched.map{$0.values}
        values["profile_percent"] = self.profilePercent
        values["lesson_watch_count"] = self.lessonWatchCount
        return values
    }
    
    var jsonValues: [String:Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["first_name"] = self.firstName
        values["last_name"] = self.lastName
        values["phone"] = self.phoneNumber
        values["email"] = self.email
        values["image"] = self.imageLink
        values["birthday"] = self.jsonFormattedBirthday
        values["country"] = self.country
        values["community_id"] = self.community?.id
        values["religious_level"] = self.religiousLevel
        values["education_id"] = self.education?.id
        values["occupation_id"] = self.occupation?.id
        values["interest_id"] = self.interest.map{$0.id}
        values["second_email"] = self.secondEmail
        values["is_presenter"] = self.isPresenter
        values["lesson_watch_count"] = self.lessonWatchCount
        return values
    }

    
    private mutating func loadProfileImageFromLocalFile() {
        if let url = self.profileImageFileURL {
            do{
                let data = try Data(contentsOf: url)
                self.profileImage = UIImage(data: data)
            }
            catch {
                
            }
        }
    }
    
}
