//
//  LessonDonationResponse.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 24/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct LessonDonationResponse: APIResponseModel {
    
    var crownId: Int?
    var donatedBy: [JTDonated]
    var lessonId = 0
    var lessId: Int {
        get{return self.lessonId}
        set(newValue) {self.lessonId = newValue}
    }
    var isGemara = false
    var isgemara:Bool {
        get{return self.isGemara}
        set(newValue){self.isGemara = newValue}
    }
    
    init?(values: [String : Any] ) {
        // --- for list
        if let donatedByValues = values["donated_by"] as? [[String: Any]] {
            self.donatedBy = donatedByValues.compactMap{JTDonated(values: $0)}
        } else if let donatedByValues = values["donated_by"] as? [String: Any]{
            if let donatedBy = JTDonated(values: donatedByValues){
                self.donatedBy = [donatedBy]
            } else { self.donatedBy = [] }
        } else { self.donatedBy = [] }
        
        if let crownId = values["crown_id"] as? Int {
            self.crownId = crownId
        } else { self.crownId = nil }
        
        if let lessonId = values["lesson_id"] as? Int {
            self.lessonId = lessonId
        } else { self.lessonId = 0 }
        
        if let isGemara = values["isGemara"] as? Bool {
            self.isGemara = isGemara
        } else { self.isGemara = false }
    }
    
    func copy()->LessonDonationResponse{
        guard let copy = LessonDonationResponse(values: self.values) else { return self }
        return copy
    }
   
    var values: [String: Any] {
        var values: [String:Any] = [:]
        values["crownId"] = self.crownId
        values["donated_by"] = self.donatedBy.map{$0.values}
        values["lesson_id"] = self.lessId
        values["isGemara"] = self.isgemara
        return values
    }
}

