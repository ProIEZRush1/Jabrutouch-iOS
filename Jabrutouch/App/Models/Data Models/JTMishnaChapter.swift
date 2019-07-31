//
//  JTMishnaChapter.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 31/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class JTMishnaChapter {
    
    var chapterName: String = ""
    var lessonsDownloaded: [JTLessonDownload] = []
    
    init(chapterName: String, lessonsDownloaded: [JTLessonDownload]) {
        self.chapterName = chapterName
        self.lessonsDownloaded = lessonsDownloaded
    }
}
