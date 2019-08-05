//בס״ד
//  JTLessonDownload.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 31/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class JTLessonDownload {
    
    var number: String = ""
    var length: String = ""
    var isAudioDownloaded: Bool = false
    var isVideoDownloaded: Bool = false
    
    init(number: String, length: String, isAudioDownloaded: Bool, isVideoDownloaded: Bool) {
        self.number = number
        self.length = length
        self.isAudioDownloaded = isAudioDownloaded
        self.isVideoDownloaded = isVideoDownloaded
    }
}
