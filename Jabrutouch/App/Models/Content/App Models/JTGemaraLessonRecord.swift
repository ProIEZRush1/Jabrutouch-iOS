//בעזרת ה׳ החונן לאדם דעת
//  JTGemaraLessonRecord.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 22/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct JTGemaraLessonRecord: Hashable {
    var lesson: JTGemaraLesson
    var masechetName: String
    var masechetId: String
    
    init(lesson: JTGemaraLesson, masechetName: String, masechetId: String) {
        self.lesson = lesson
        self.masechetName = masechetName
        self.masechetId = masechetId
    }
    
    init?(values: [String:Any]) {
        if let lessonValues = values["lesson"] as? [String:Any] {
            if let lesson = JTGemaraLesson(values: lessonValues) {
                self.lesson = lesson
            } else { return nil }
        } else { return nil }
        
        if let masechetName = values["masechetName"] as? String {
            self.masechetName = masechetName
        } else { return nil }
        
        if let masechetId = values["masechetId"] as? String {
            self.masechetId = masechetId
        } else { return nil }
    }
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["lesson"] = self.lesson.values
        values["masechetName"] = masechetName
        values["masechetId"] = self.masechetId
        return values
    }
}
