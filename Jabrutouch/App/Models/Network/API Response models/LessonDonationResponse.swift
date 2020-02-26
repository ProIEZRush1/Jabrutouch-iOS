//
//  LessonDonationResponse.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 24/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct LessonDonationResponse: APIResponseModel {
    
    var donatedBy: [JTDonated]
    
    init?(values: [String : Any]) {
        if let donatedByValues = values["donated_by"] as? [[String: Any]] {
            self.donatedBy = donatedByValues.compactMap{JTDonated(values: $0)}
        } else {
            self.donatedBy = []
        }
    }
}

