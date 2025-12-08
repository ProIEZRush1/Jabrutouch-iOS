// ב״ה
//  OTPSecurityManager.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 15/11/2022.
//  Copyright © 2022 Ravtech. All rights reserved.
//

import Foundation
import SwiftyRSA
import UIKit

class OTPSecurityManager {

    private static var manager: OTPSecurityManager?

    private init() {}

    class func encryptMsg(phone:String) -> String? {
        do {
            // Create dictionary with phone
            let payload: [String: String] = ["phone": phone]

            guard let jsonString = Utils.convertDictionaryToString(payload) else { return nil }
            let publicKey = try PublicKey(pemNamed: "otp_encrypt_public")

            let clear = try ClearMessage(string: jsonString, using: .utf8)
            let encrypted = try clear.encrypted(with: publicKey, padding: SecPadding.OAEP)

            let secretBytesHex = encrypted.data.map { String(format: "%02hhx", $0) }.joined()

            return secretBytesHex
        } catch {
            print("encryption error: ", error)
            return nil
        }
    }

    /// Encrypt email message for email verification (similar to phone encryption)
    class func encryptEmail(email: String) -> String? {
        do {
            // Create dictionary with email
            let payload: [String: String] = ["email": email]

            guard let jsonString = Utils.convertDictionaryToString(payload) else { return nil }
            let publicKey = try PublicKey(pemNamed: "otp_encrypt_public")

            let clear = try ClearMessage(string: jsonString, using: .utf8)
            let encrypted = try clear.encrypted(with: publicKey, padding: SecPadding.OAEP)

            let secretBytesHex = encrypted.data.map { String(format: "%02hhx", $0) }.joined()

            return secretBytesHex
        } catch {
            print("email encryption error: ", error)
            return nil
        }
    }

    /// Encrypt email and verification code for validate_email_code API
    class func encryptEmailCode(email: String, code: String) -> String? {
        do {
            // Create dictionary with email and code
            let payload: [String: String] = ["email": email, "code": code]

            guard let jsonString = Utils.convertDictionaryToString(payload) else { return nil }
            let publicKey = try PublicKey(pemNamed: "otp_encrypt_public")

            let clear = try ClearMessage(string: jsonString, using: .utf8)
            let encrypted = try clear.encrypted(with: publicKey, padding: SecPadding.OAEP)

            let secretBytesHex = encrypted.data.map { String(format: "%02hhx", $0) }.joined()

            return secretBytesHex
        } catch {
            print("email code encryption error: ", error)
            return nil
        }
    }
}
