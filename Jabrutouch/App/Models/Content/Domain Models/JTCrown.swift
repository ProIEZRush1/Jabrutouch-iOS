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
    var dollarPerCrown : Int
    
    init?(values: [String:Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let paymentType = values["payment_type"] as? String {
            self.paymentType = paymentType
        } else { return nil }
        
        if let dollarPerCrown = values["dollar_per_crown"] as? Int {
            self.dollarPerCrown = dollarPerCrown
        } else { return nil }
        
    }
    
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["payment_type"] = self.paymentType
        values["dollar_per_crown"] = self.dollarPerCrown
        
        return values
    }
}
