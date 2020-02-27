//
//  UserDonationResponse.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 24/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct UserDonationResponse: APIResponseModel {
    
    var userDonation: JTUserDonation
    
    init?(values: [String : Any]) {
        if let userDonation = JTUserDonation(values: values) {
            self.userDonation = userDonation
        } else {
            return nil
        }
    }
}
