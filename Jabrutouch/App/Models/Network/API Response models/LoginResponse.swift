//בעזרת ה׳ החונן לאדם דעת
//  LoginResponse.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 30/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct LoginResponse: APIResponseModel {
    var user: JTUser
    
    init?(values: [String : Any]) {
        if let user = JTUser(values: values) {
            self.user = user
        } else { return nil }
    }
}
