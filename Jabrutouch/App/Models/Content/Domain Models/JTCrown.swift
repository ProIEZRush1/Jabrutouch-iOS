//
//  JTCrown.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 09/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct JTCrown {
    
    var id: Int
    var paymentType: String
    var dollarPerCrown : Float
    var fromSumDonation: Int
    var toSumDonation:Int
    
    init?(values: [String:Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let paymentType = values["payment_type"] as? String {
            self.paymentType = paymentType
        } else { return nil }
        
        if let dollarPerCrown = values["price"] as? String {
            self.dollarPerCrown = (dollarPerCrown as NSString).floatValue
        } else { return nil }
        
        if let fromSumDonation = values["from_sum_donation"] as? Int {
            self.fromSumDonation = fromSumDonation
        } else { return nil }
        
        if let toSumDonation = values["to_sum_donation"] as? Int {
            self.toSumDonation = toSumDonation
        } else { return nil }
    }
    
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["payment_type"] = self.paymentType
        values["price"] = self.dollarPerCrown
        values["from_sum_donation"] = self.fromSumDonation
        values["to_sum_donation"] = self.toSumDonation
        
        return values
    }
}
