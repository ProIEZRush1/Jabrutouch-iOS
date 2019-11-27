//
//  JTVideoPart.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 26/11/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct JTVideoPart {

    var id: Int
    var partTitle: String
    var videoPart: String
    
    init?(values: [String:Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let partTitle = values["part_title"] as? String {
            self.partTitle = partTitle
        } else { return nil }
        
        if let videoPart = values["video_part_time_line"] as? String {
            self.videoPart = videoPart
        } else { return nil }

    }
    
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["part_title"] = self.partTitle
        values["video_part_time_line"] = self.videoPart
        
        return values
    }
}
