//בעזרת ה׳ החונן לאדם דעת
//  JTMishnaLessonRecord.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 22/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct JTMishnaLessonRecord: Hashable {
    var lesson: JTMishnaLesson
    var masechetName: String
    var masechetId: String
    var chapter: String
    var sederId: String
    
    init(lesson: JTMishnaLesson, masechetName: String, masechetId: String, chapter: String, sederId: String) {
        self.lesson = lesson
        self.masechetName = masechetName
        self.masechetId = masechetId
        self.chapter = chapter
        self.sederId = sederId
    }
    
    init?(values: [String:Any]) {
        if let lessonValues = values["lesson"] as? [String:Any] {
            if let lesson = JTMishnaLesson(values: lessonValues) {
                self.lesson = lesson
            } else { return nil }
        } else { return nil }
        
        if let masechetName = values["masechetName"] as? String {
            self.masechetName = masechetName
        } else { return nil }
        
        if let chapter = values["chapter"] as? String {
            self.chapter = chapter
        } else { return nil }
        
        if let masechetId = values["masechetId"] as? String {
            self.masechetId = masechetId
        } else { return nil }
        
        if let sederId = values["sederId"] as? String {
            self.sederId = sederId
        } else { return nil }
    }
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["lesson"] = self.lesson.values
        values["masechetName"] = masechetName
        values["masechetId"] = self.masechetId
        values["chapter"] = self.chapter
        values["sederId"] = self.sederId
        return values
    }
}
