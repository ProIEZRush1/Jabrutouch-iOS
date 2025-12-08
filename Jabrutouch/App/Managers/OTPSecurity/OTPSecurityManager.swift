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
import CommonCrypto

class OTPSecurityManager {

    private static var manager: OTPSecurityManager?

    private init() {}

    // MARK: - Hybrid Encryption (AES + RSA) for large payloads

    /// Encrypt signup data using hybrid encryption (AES-256-CBC + RSA-OAEP)
    /// Returns format: encrypted_key_hex:iv_hex:encrypted_data_hex
    /// This is needed because RSA-2048 with OAEP can only encrypt ~190 bytes,
    /// but signup data with FCM token exceeds this limit.
    class func encryptSignUpData(email: String, password: String, firstName: String, lastName: String,
                                  phone: String, country: String, deviceType: String, fcmToken: String) -> String? {
        do {
            // Build JSON payload
            let payload: [String: String] = [
                "email": email,
                "password": password,
                "first_name": firstName,
                "last_name": lastName,
                "phone": phone,
                "country": country,
                "device_type": deviceType,
                "fcm_token": fcmToken
            ]

            guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
                print("Failed to serialize signup payload to JSON")
                return nil
            }

            // Generate random AES-256 key (32 bytes)
            var aesKey = [UInt8](repeating: 0, count: 32)
            let keyStatus = SecRandomCopyBytes(kSecRandomDefault, aesKey.count, &aesKey)
            guard keyStatus == errSecSuccess else {
                print("Failed to generate random AES key")
                return nil
            }

            // Generate random IV (16 bytes for AES-CBC)
            var iv = [UInt8](repeating: 0, count: 16)
            let ivStatus = SecRandomCopyBytes(kSecRandomDefault, iv.count, &iv)
            guard ivStatus == errSecSuccess else {
                print("Failed to generate random IV")
                return nil
            }

            // Encrypt data with AES-256-CBC
            guard let encryptedData = aesEncrypt(data: jsonData, key: Data(aesKey), iv: Data(iv)) else {
                print("AES encryption failed")
                return nil
            }

            // Encrypt AES key with RSA-OAEP
            let publicKey = try PublicKey(pemNamed: "otp_encrypt_public")
            let aesKeyData = Data(aesKey)
            let clearKey = ClearMessage(data: aesKeyData)
            let encryptedKey = try clearKey.encrypted(with: publicKey, padding: SecPadding.OAEP)

            // Convert to hex strings
            let encryptedKeyHex = encryptedKey.data.map { String(format: "%02hhx", $0) }.joined()
            let ivHex = Data(iv).map { String(format: "%02hhx", $0) }.joined()
            let encryptedDataHex = encryptedData.map { String(format: "%02hhx", $0) }.joined()

            // Format: encrypted_key_hex:iv_hex:encrypted_data_hex
            let secretMessage = "\(encryptedKeyHex):\(ivHex):\(encryptedDataHex)"
            print("encryptSignUpData: using hybrid encryption, message length: \(secretMessage.count)")
            return secretMessage

        } catch {
            print("hybrid encryption error: ", error)
            return nil
        }
    }

    /// AES-256-CBC encryption with PKCS7 padding
    private class func aesEncrypt(data: Data, key: Data, iv: Data) -> Data? {
        let dataBytes = [UInt8](data)
        let keyBytes = [UInt8](key)
        let ivBytes = [UInt8](iv)

        // Calculate buffer size (data + padding)
        let bufferSize = dataBytes.count + kCCBlockSizeAES128
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        var numBytesEncrypted: size_t = 0

        let cryptStatus = CCCrypt(
            CCOperation(kCCEncrypt),
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(kCCOptionPKCS7Padding),
            keyBytes, key.count,
            ivBytes,
            dataBytes, dataBytes.count,
            &buffer, bufferSize,
            &numBytesEncrypted
        )

        guard cryptStatus == kCCSuccess else {
            print("AES encryption failed with status: \(cryptStatus)")
            return nil
        }

        return Data(buffer.prefix(numBytesEncrypted))
    }

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
