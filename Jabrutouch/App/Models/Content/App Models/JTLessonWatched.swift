//
//  JTLessonWatched.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 20/11/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct JTLessonWatched {
    var lessonId: Int
    var duration: TimeInterval
    
    init?(values: [String:Any]) {
        if let lessonId = values["lessonId"] as? Int {
            self.lessonId = lessonId
        } else { return nil }
        
        if let duration = values["duration"] as? Double {
            self.duration = duration
        } else { return nil }

    }
    
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["lessonId"] = self.lessonId
        values["duration"] = self.duration
        
        return values
    }
}
