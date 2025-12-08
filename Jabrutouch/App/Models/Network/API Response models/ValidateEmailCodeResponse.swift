//
//  ValidateEmailCodeResponse.swift
//  Jabrutouch
//
//  Created by Claude Code on 2025.
//  Copyright © 2025 Ravtech. All rights reserved.
//

import Foundation

struct ValidateEmailCodeResponse: APIResponseModel {

    var id: Int
    var email: String

    init?(values: [String:Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }

        if let email = values["email"] as? String {
            self.email = email
        } else { return nil }
    }
}
