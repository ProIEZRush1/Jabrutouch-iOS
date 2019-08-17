//בעזרת ה׳ החונן לאדם דעת
//  GetGemaraLessonsResponse.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct GetGemaraLessonsResponse: APIResponseModel {
    
    var lessons: [JTGemaraLesson]
    
    init?(values: [String : Any]) {
        
        if let lessonsValues = values["pages"] as? [[String:Any]] {
            self.lessons = lessonsValues.compactMap{JTGemaraLesson(values: $0)}
        } else {
            return nil
        }
    }
}
