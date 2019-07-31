//
//  JTLessonDownload.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 31/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class JTLessonDownload {
    
    var lessonNumber: String = ""
    var isAudioDownloaded: Bool = false
    var isVideoDownloaded: Bool = false
    
    init(lessonNumber: String, isAudioDownloaded: Bool, isVideoDownloaded: Bool) {
        self.lessonNumber = lessonNumber
        self.isAudioDownloaded = isAudioDownloaded
        self.isVideoDownloaded = isVideoDownloaded
    }
}
