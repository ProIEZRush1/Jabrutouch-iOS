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
        case donationPending = "DonationPending"
        case lessonAnalisticDuration = "LessonAnalisticDuration"
        case lessonAnalitics = "LessonAnalitics"
        case lessonDonation = "LessonDonation"
        case currentFcmToken = "CurrentFcmToken"
        case campaignPopUpDetails = "CampaignPopUpDetails"
        case latestNewsItems = "LatestNewsItems"
        case surveyLastCheckedInfo = "SurveyLastCheckedInfo"
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
    
    var currentFcmToken: String? {
        get {
            return self.defaults.string(forKey: UserDefaultsKeys.currentFcmToken.rawValue)
        }
        set (fcmToken){
            self.defaults.set(fcmToken, forKey: UserDefaultsKeys.currentFcmToken.rawValue)
            self.defaults.synchronize()
        }
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
    
    var lessonDonation: [LessonDonationResponse]? {
        get {
            guard let values = self.defaults.object(forKey: UserDefaultsKeys.lessonDonation.rawValue) as? [[String:Any]] else { return []}
            return values.compactMap{LessonDonationResponse(values: $0)}
        }
        set (lessonDonation) {
            self.defaults.set(lessonDonation?.map{$0.values}, forKey: UserDefaultsKeys.lessonDonation.rawValue)
            self.defaults.synchronize()
        }
    }
    
    var lessonAnalisticDuration: Int64? {
        get {
            return Int64(self.defaults.integer(forKey: UserDefaultsKeys.lessonAnalisticDuration.rawValue))
        }
        set (duration) {
            self.defaults.set(duration, forKey: UserDefaultsKeys.lessonAnalisticDuration.rawValue)
            self.defaults.synchronize()
        }
    }
    
    var lessonAnalitics: JTLessonAnalitics? {
        get {
            guard let values = self.defaults.object(forKey: UserDefaultsKeys.lessonAnalitics.rawValue) as? [String:Any] else { return nil }
            return JTLessonAnalitics(values: values)
        }
        set (lesson) {
            self.defaults.set(lesson?.values, forKey: UserDefaultsKeys.lessonAnalitics.rawValue)
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
    
    var donationPending: Bool {
        get {
            return self.defaults.bool(forKey: UserDefaultsKeys.donationPending.rawValue)
        }
        set (value) {
            self.defaults.set(value, forKey: UserDefaultsKeys.donationPending.rawValue)
            self.defaults.synchronize()
        }
    }
    
    var campaignPopUpDetails: JTCampaignPopup? {
        get {
            guard let values = self.defaults.object(forKey: UserDefaultsKeys.campaignPopUpDetails.rawValue) as? [String:Any] else { return nil }
            return JTCampaignPopup(values: values)
        }
        set (detail) {
            self.defaults.set(detail?.values, forKey: UserDefaultsKeys.campaignPopUpDetails.rawValue)
            self.defaults.synchronize()
        }
    }
        
    var latestNewsItems: [JTNewsFeedItem]? {
        get {
            guard let values = self.defaults.object(forKey: UserDefaultsKeys.latestNewsItems.rawValue) as? [[String:Any]] else { return []}
            return values.compactMap{JTNewsFeedItem(values: $0)}
        }
        set (latestNewsItems) {
            self.defaults.set(latestNewsItems?.map{$0.values}, forKey: UserDefaultsKeys.latestNewsItems.rawValue)
            self.defaults.synchronize()
        }
    }
    
    var surveyLastCheckedInfo: JTSurveyCheckedInfo? {
        get {
            guard let values = self.defaults.object(forKey: UserDefaultsKeys.surveyLastCheckedInfo.rawValue) as? [String:Any] else { return nil }
            return JTSurveyCheckedInfo(values: values)
        }
        set (info) {
            self.defaults.set(info?.values, forKey: UserDefaultsKeys.surveyLastCheckedInfo.rawValue)
            self.defaults.synchronize()
        }
    }
}
