//
//  JTDeepLinkCoupone.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 02/08/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

class JTDeepLinkCoupone {
    
    
    //============================================
    // MARK: - Stored Properties
    //============================================
    var type: String
    var couponDistributor: String
    var couponTitle: String
    var couponSum: String
    
    
    //============================================
    // MARK: - Initializer
    //============================================
    
    init?(values: [String: String]) {
        
        if let type = values["type"] {
            self.type = type
        } else { return  nil }
        
        if let couponDistributor = values["coupon_distributor"] {
            self.couponDistributor = couponDistributor
        } else { return  nil }
        
        if let couponTitle = values["coupon_title"] {
            self.couponTitle = couponTitle
        } else { return nil }
        
        if let couponSum = values["coupon_sum"]  {
            self.couponSum = couponSum
        } else { return nil }

    }
    
}

