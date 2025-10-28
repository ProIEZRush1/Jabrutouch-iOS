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

    /// Get unique device identifier for security and rate limiting
    /// Uses Apple's recommended identifierForVendor
    private class func getDeviceIdentifier() -> String? {
        // Use identifierForVendor (recommended by Apple)
        // This is unique per app vendor and persists across app installs
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            return uuid
        }

        // Fallback: generate a persistent identifier
        let defaults = UserDefaults.standard
        let key = "JabrutouchDeviceIdentifier"

        if let existingId = defaults.string(forKey: key) {
            return existingId
        }

        // Generate new UUID and persist it
        let newId = UUID().uuidString
        defaults.set(newId, forKey: key)
        defaults.synchronize()

        return newId
    }

    class func encryptMsg(phone:String) -> String? {
        do {
            // Create dictionary with phone and device ID
            var payload: [String: String] = ["phone": phone]

            // Add device identifier for enhanced security and rate limiting
            if let deviceId = getDeviceIdentifier() {
                payload["imei"] = deviceId
                print("OTPSecurityManager: Including device ID in encrypted payload")
            } else {
                print("OTPSecurityManager: Warning - Device ID not available")
            }

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
}
