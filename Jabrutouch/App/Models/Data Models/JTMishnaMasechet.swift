//בס״ד
//  JTMishnaMasechet.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 31/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class JTMishnaMasechet {
    
    var name: String = ""
    var chapters: [JTMishnaChapter] = []
    
    init(name: String, chapters: [JTMishnaChapter]) {
        self.name = name
        self.chapters = chapters
    }
}
