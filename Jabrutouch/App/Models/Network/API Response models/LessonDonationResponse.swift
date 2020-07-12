//
//  LessonDonationResponse.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 24/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct LessonDonationResponse: APIResponseModel {
    
    var crownId: Int?
    var donatedBy: [JTDonated]
    //    var donatedBy: JTDonated?
    
    init?(values: [String : Any]) {
        // --- for list
        if let donatedByValues = values["donated_by"] as? [[String: Any]] {
            self.donatedBy = donatedByValues.compactMap{JTDonated(values: $0)}
        } else {
            self.donatedBy = []
        }
        //         --- for object
        if let donatedByValues = values["donated_by"] as? [String: Any]{
            if let donatedBy = JTDonated(values: donatedByValues){
                self.donatedBy.append(donatedBy)
            } else { self.donatedBy = [] }
        } else { self.donatedBy = [] }
        
        if let crownId = values["crown_id"] as? Int {
            self.crownId = crownId
        } else { self.crownId = nil }
        
    }
}

