//בעזרת ה׳ החונן לאדם דעת
//  GetMishnaLessonsResponse.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct GetMishnaLessonsResponse: APIResponseModel {
    
    var lessons: [JTMishnaLesson]
    
    init?(values: [String : Any]) {
        
        if let lessonsValues = values["mishnayot"] as? [[String:Any]] {
            self.lessons = lessonsValues.compactMap{JTMishnaLesson(values: $0)}
        } else {
            return nil
        }
    }
}

struct GetMishnaLessonResponse: APIResponseModel {
    
    var lesson: JTMishnaLesson
    
    init?(values: [String : Any]) {
        if let lesson = JTMishnaLesson(values: values) {
            self.lesson = lesson
        }
        else {
            return nil
        }
    }
}
