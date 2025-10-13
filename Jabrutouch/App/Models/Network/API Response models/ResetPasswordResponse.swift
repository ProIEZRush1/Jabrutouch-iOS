//
//  ResetPasswordResponse.swift
//  Jabrutouch
//
//  Created by Claude Code on 12/10/2025.
//  Copyright © 2025 Ravtech. All rights reserved.
//

import Foundation

struct ResetPasswordResponse: APIResponseModel {

    let success: Bool
    let message: String
    let userEmail: String?

    init?(values: [String : Any]) {
        if let success = values["success"] as? Bool {
            self.success = success
        } else { return nil }

        if let message = values["message"] as? String {
            self.message = message
        } else { return nil }

        self.userEmail = values["user_email"] as? String
    }
}

// Codable extension for future use
extension ResetPasswordResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case userEmail = "user_email"
    }
}
