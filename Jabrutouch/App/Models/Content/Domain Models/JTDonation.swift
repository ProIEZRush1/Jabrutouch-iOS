//
//  JTDonation.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 09/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct JTDonation {
    
    var crowns: [JTCrown] = []
    var dedication: [JTDedication] = []
    
    
    init?(values: [String:Any]) {
        if let crownsValues = values["crowns"] as? [[String: Any]] {
            self.crowns = crownsValues.compactMap{JTCrown(values: $0)}
        } else { return nil }
        
        if let dedicationValues = values["dedication"] as? [[String: Any]] {
            self.dedication = dedicationValues.compactMap{ JTDedication(values: $0)}
        } else { return nil }
        
    }
    
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["crowns"] = self.crowns
        values["dedication"] = self.dedication
        
        return values
    }
}
