//
//  DonationResponse.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 09/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct DonationResponse: APIResponseModel {
    
    var donation: JTDonation
    
    init?(values: [String : Any]) {
        if let donation = JTDonation(values: values) {
            self.donation = donation
        } else {
            return nil
        }
    }
}
