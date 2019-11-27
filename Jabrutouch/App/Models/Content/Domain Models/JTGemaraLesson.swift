//בעזרת ה׳ החונן לאדם דעת
//  JTGemaraLesson.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class JTGemaraLesson: JTLesson  {
    
    //============================================
    // MARK: - Stored Properties
    //============================================
    
    var page: Int
    
    
    //============================================
    // MARK: - Initializer
    //============================================
    
    override init?(values: [String:Any]) {
        if let page = values["page_number"] as? Int {
            self.page = page
        } else { return nil }
        
        super.init(values:values)
    }
    
    override var values: [String: Any] {
        var values: [String:Any] = [:]
        values["id"] = super.id
        values["chapter"] = super.chapter
        values["page_number"] = self.page
        values["duration"] = super.duration
        values["audio"] = super.audioLink
        values["video"] = super.videoLink
        values["page"]  = super.textLink
        values["video_part"] = self.videoPart.map{$0.values}
        values["gallery"] = self.gallery.map{$0.values}
        values["presenter"] = super.presenter?.values
        return values
    }
}



