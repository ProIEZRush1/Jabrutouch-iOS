//בס״ד
//  JTGemaraMasechet.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 05/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class JTGemaraMasechet {
    
    var name: String = ""
    var lessons: [JTLessonDownload] = []
    
    init(name: String, lessons: [JTLessonDownload]) {
        self.name = name
        self.lessons = lessons
    }
}
