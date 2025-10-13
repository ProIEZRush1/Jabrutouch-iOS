//
//  ForgotPasswordResponse.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 03/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct ForgotPasswordResponse: APIResponseModel {

    let message: String
    let status: Bool

    // Optional new fields for v2 API (backward compatible)
    let resetMethod: String?      // "email_password" or "email_link"
    let resetLinkSent: Bool?      // true if reset link was sent
    let linkExpiresIn: Int?       // seconds until link expires

    // Legacy init for backward compatibility with old dictionary-based parsing
    init?(values: [String : Any]) {
        if let message = values["message"] as? String {
            self.message = message
        } else { return nil }

        // Support both new and old API response formats
        if let status = values["success"] as? Bool {
            // New secure password reset API format
            self.status = status
        } else if let status = values["user_exist_status"] as? Bool {
            // Legacy API format (old reset_password endpoint)
            self.status = status
        } else {
            return nil
        }

        // Optional new fields (won't break if missing)
        self.resetMethod = values["reset_method"] as? String
        self.resetLinkSent = values["reset_link_sent"] as? Bool
        self.linkExpiresIn = values["link_expires_in"] as? Int
    }
}

// Extension for future Codable migration (optional, when backend is ready)
extension ForgotPasswordResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case message
        case status = "user_exist_status"
        case resetMethod = "reset_method"
        case resetLinkSent = "reset_link_sent"
        case linkExpiresIn = "link_expires_in"
    }
}
