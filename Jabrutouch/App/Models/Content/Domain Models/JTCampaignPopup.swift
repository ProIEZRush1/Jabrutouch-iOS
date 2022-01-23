//
//  JTCampaignPopup.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 02/09/2020.
//  Edited by Avraham Kirsch on 23/01/2022.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct JTCampaignPopup {
    var currentDate: Date
    var agree: Bool = false
    
    init?(currentDate: Date) {
        self.currentDate = currentDate
    }
    
    init?(values:[String: Any]) {
        if let currentDate = values["currentDate"] as? Date {
            self.currentDate = currentDate
        } else {
            return nil
        }
        if let agree = values["agree"] as? Bool {
            self.agree = agree
        }
    }
    
    var values: [String:Any] {
            var values: [String:Any] = [:]
            values["currentDate"] = self.currentDate
            values["agree"] = self.agree
        
            return values
        }
}
