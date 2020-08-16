//
//  CouponResponse.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 04/08/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct CouponResponse: APIResponseModel {
    
    var coupon: Int
    var dedicationTemplate: String
    var commit: Bool = true
    
    
    init?(values: [String : Any]) {
        if let coupon = values["coupon"] as? Int {
            self.coupon = coupon
        } else { return nil }
        
        if let dedicationTemplate = values["dedication_template"] as? String {
            self.dedicationTemplate = dedicationTemplate
        } else { dedicationTemplate = "" }
        
        if let commit = values["commit"] as? Bool {
            self.commit = commit
        } else { commit = true }
    }
}
