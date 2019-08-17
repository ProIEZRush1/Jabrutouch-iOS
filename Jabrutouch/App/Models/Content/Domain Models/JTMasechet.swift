//בעזרת ה׳ החונן לאדם דעת
//  JTMasechet.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 13/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct JTMasechet {
    
    var id: Int
    var order: Int
    var name: String
    var chaptersCount: Int
    var pagesCount: Int
    var mishnaShiurimCountPerChapter: [String:Int]
    
    init?(values: [String:Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let order = values["order"] as? Int {
            self.order = order
        } else { return nil }
        
        if let name = values["name"] as? String {
            self.name = name
        } else { return nil }
        
        if let chaptersCount = values["chapters"] as? Int {
            self.chaptersCount = chaptersCount
        } else { return nil }
        
        if let pagesCount = values["pages"] as? Int {
            self.pagesCount = pagesCount
        } else { return nil }
        
        if let shiurimCountPerChapterValues = values["chapters_list"] as? [[String:Int]] {
            self.mishnaShiurimCountPerChapter = [:]
            for chapterValues in shiurimCountPerChapterValues {
                if let chapter = chapterValues["chapter"], let mishnayotCount = chapterValues["mishnayots"] {
                    self.mishnaShiurimCountPerChapter["\(chapter)"] = mishnayotCount
                }
            }
        } else { self.mishnaShiurimCountPerChapter = [:] }
        
    }
}
