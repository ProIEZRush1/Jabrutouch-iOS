//
//  JTMishnaChapter.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 31/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class JTMishnaChapter {
    
    var name: String = ""
    var lessonsDownloaded: [JTLessonDownload] = []
    
    init(name: String, lessonsDownloaded: [JTLessonDownload]) {
        self.name = name
        self.lessonsDownloaded = lessonsDownloaded
    }
}
