//
//  SignUpResponse.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 30/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct SignUpResponse: APIResponseModel {
    
    var user: JTUser
    
    init?(values: [String : Any]) {
        if let user = JTUser(values: values) {
            self.user = user
        } else { return nil }
    }
}
