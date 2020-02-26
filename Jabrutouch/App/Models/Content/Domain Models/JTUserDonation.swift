//
//  JTUserDonation.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 24/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct JTUserDonation {
    
    var allCrowns: Int
    var unUsedCrowns: Int
    var likes: Int
    var watchCount: Int
    
    init?(values: [String:Any]) {
        if let allCrowns = values["all_crowns"] as? Int {
            self.allCrowns = allCrowns
        } else { return nil }
        
        if let unUsedCrowns = values["unused_crowns"] as? Int {
            self.unUsedCrowns = unUsedCrowns
        } else { return nil }
        
        if let likes = values["likes"] as? Int {
            self.likes = likes
        } else { return nil }
        
        if let watchCount = values["watch_count"] as? Int {
            self.watchCount = watchCount
        } else { return nil }
        
    }
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["all_crowns"] = self.allCrowns
        values["unused_crowns"] = self.unUsedCrowns
        values["likes"] = self.likes
        values["watch_count"] = self.watchCount
        
        return values
    }
}
