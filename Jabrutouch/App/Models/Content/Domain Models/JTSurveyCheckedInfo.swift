//
//  JTSurveyCheckedInfo.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 24/01/2022.
//  Copyright © 2022 Ravtech. All rights reserved.
//

import Foundation
struct JTSurveyCheckedInfo {
    var lastCheckedDate: Date
    
    init?(lastCheckedDate: Date) {
        self.lastCheckedDate = lastCheckedDate
    }
    
    init?(values:[String: Any]) {
        if let lastCheckedDate = values["lastCheckedDate"] as? Date {
            self.lastCheckedDate = lastCheckedDate
        } else {
            return nil
        }
    }
    
    var values: [String:Any] {
            var values: [String:Any] = [:]
            values["lastCheckedDate"] = self.lastCheckedDate
        
            return values
        }
}
