//
//  JTLessonAnalitics.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 02/07/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//


import Foundation
struct JTLessonAnaliticsDuration {
    var duration: TimeInterval
}

struct JTLessonAnalitics {
    
    var eventType: AnalyticsEventType
    var category: AnalyticsEventCategory
    var mediaType: JTLessonMediaType
    var lessonId: Int
    var duration: Int64
    var online: Bool
    
    init(eventType: AnalyticsEventType, category: AnalyticsEventCategory, mediaType: JTLessonMediaType, lessonId: Int, duration: Int64, online: Bool ) {
        self.eventType = eventType
        self.category = category
        self.mediaType = mediaType
        self.lessonId = lessonId
        self.duration = duration
        self.online = online
    }
    
    init?(values: [String:Any]) {
        
        if let event = values["event"] as? AnalyticsEventType {
            self.eventType = event
        } else {
            if let event = AnalyticsEventType(rawValue: values["event"] as! String) {
                self.eventType = event
            } else { return nil }
        }
        
        if let category = values["category"] as? AnalyticsEventCategory {
            self.category = category
        } else {
            if let category = AnalyticsEventCategory(rawValue: values["category"] as! String ){
                self.category = category
            } else { return nil }
        }
        
        if let mediaType = values["media_type"] as? JTLessonMediaType {
            self.mediaType = mediaType
        } else {
            if let mediaType = JTLessonMediaType(rawValue: values["media_type"] as! String ) {
                self.mediaType = mediaType
            } else { return nil }
        }
        
        if let lessonId = values["page_id"] as? Int {
            self.lessonId = lessonId
        } else { return nil }
        if let duration = values["duration"] as? Int64 {
            self.duration = duration
        } else { return nil }
        if let online = values["online"] as? Bool {
            self.online = online
        } else { return nil }
    }
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["event"] = self.eventType.rawValue
        values["category"] = self.category.rawValue
        values["media_type"] = self.mediaType.rawValue
        values["page_id"] = self.lessonId
        values["duration"] = self.duration
        values["online"] = self.online
        return values
    }
}
