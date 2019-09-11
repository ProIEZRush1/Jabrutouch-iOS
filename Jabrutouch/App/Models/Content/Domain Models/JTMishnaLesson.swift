//בעזרת ה׳ החונן לאדם דעת
//  JTMishnaLesson.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class JTMishnaLesson: JTLesson {
    
    //============================================
    // MARK: - Stored Properties
    //============================================
    var mishna: Int
    
    
    //============================================
    // MARK: - Initializer
    //============================================
    
    override init?(values: [String:Any]) {
        if let mishna = values["mishna"] as? Int {
            self.mishna = mishna
        } else { return nil }
        
        super.init(values:values)
    }
    
    override var values: [String: Any] {
        var values: [String:Any] = [:]
        values["id"] = super.id
        values["chapter"] = super.chapter
        values["mishna"] = self.mishna
        values["duration"] = super.duration
        values["audio"] = super.audioLink
        values["video"] = super.videoLink
        values["page"]  = super.textLink
        values["video_part"] = super.videoPart
        values["gallery"] = super.gallery
        values["presenter"] = super.presenter?.values
        return values
    }
}
