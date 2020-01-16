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
    var education: String?
    var occupation: String?
    var interest: [String]
    var secondEmail: String
    var isPresenter: Bool
    var token: String
    var profileImage: UIImage?
    var lessonWatched: [JTLessonWatched] = []
    
    var profileImageFileName: String {
        return "profile_image_\(self.id)"
    }
    
    var profileImageFileURL: URL? {
        return FileDirectory.cache.url?.appendingPathComponent(self.profileImageFileName)
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
        } else { return nil }
        
        if let communityValues = values["community"] as? [String:Any] {
            if let community = JTCommunity(values: communityValues) {
                self.community = community
            }
        }
        
        if let lessonWatchedValues = values["lessonWatched"] as? [[String:Any]] {
            self.lessonWatched = lessonWatchedValues.compactMap{JTLessonWatched(values: $0)}
        }
        
        self.imageLink = values["image"] as? String ?? ""
        self.birthdayString = values["birthday"] as? String ?? ""
        self.country = values["country"] as? String ?? ""
        self.religiousLevel = values["religious_level"] as? Int
        self.education = values["education"] as? String
        self.occupation = values["occupation"] as? String
        self.interest = values["interest"] as? [String] ?? []
        self.secondEmail = values["second_email"] as? String ?? ""
        self.isPresenter = values["is_presenter"] as? Bool ?? false
        
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
        values["education"] = self.education
        values["occupation"] = self.occupation
        values["interest"] = self.interest
        values["second_email"] = self.secondEmail
        values["is_presenter"] = self.isPresenter
        values["token"] = self.token
        values["lessonWatched"] = self.lessonWatched.map{$0.values}
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
