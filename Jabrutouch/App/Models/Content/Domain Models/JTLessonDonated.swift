//
//  JTLessonDonated.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 01/03/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct JTLessonDonated {
    
    var lessonDonated: Int
    var donated: Bool
    
    init?(values: [String:Any]) {
        if let lessonDonated = values["lesson_donated"] as? Int {
            self.lessonDonated = lessonDonated
        } else { return nil }
        
        if let donated = values["donated"] as? Bool {
            self.donated = donated
        } else { return nil }
        
    }
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["lesson_donated"] = self.lessonDonated
        values["donated"] = self.donated
        
        return values
    }
}
