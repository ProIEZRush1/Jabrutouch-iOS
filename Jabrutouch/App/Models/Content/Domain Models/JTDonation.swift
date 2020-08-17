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
        
        if let dedicationValues = values["dedication_templates"] as? [[String: Any]] {
            self.dedication = dedicationValues.compactMap{ JTDedication(values: $0)}
        } else { return nil }
        
    }
    
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["crowns"] = self.crowns
        values["dedication_templates"] = self.dedication
        
        return values
    }
    
    func crownPrice(value: Int, type: String) -> (price: Int, id: Int) {
        var perCrown = 0
        var id = 0
        if type == "regular" {
            let price =  crowns.filter{$0.paymentType == "regular" && value >= $0.fromSumDonation && value <= $0.toSumDonation}
            if !price.isEmpty {
                perCrown = Int(round(Float(value) / price[0].dollarPerCrown))
                id = price[0].id
            }
        }
        else if type == "subscription" {
            let price =  crowns.filter{$0.paymentType == "subscription" && value >= $0.fromSumDonation && value <= $0.toSumDonation}
            perCrown = Int(round(Float(value) / price[0].dollarPerCrown))
            id = price[0].id
        }
        return (perCrown, id)
    }
}
