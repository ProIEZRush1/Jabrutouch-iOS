//בס״ד
//  JTDownload.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 23/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class JTDownload {
    
    var book: String = ""
    var chapter: String = ""
    var number: String = ""
    var hasAudio: Bool = false
    var hasVideo: Bool = false
    
    init(book: String, chapter: String, number: String, hasAudio: Bool, hasVideo: Bool) {
        self.book = book
        self.chapter = chapter
        self.number = number
        self.hasAudio = hasAudio
        self.hasVideo = hasVideo
    }
}
