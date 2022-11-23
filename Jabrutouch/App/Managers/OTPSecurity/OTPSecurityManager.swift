// ב״ה
//  OTPSecurityManager.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 15/11/2022.
//  Copyright © 2022 Ravtech. All rights reserved.
//

import Foundation
import SwiftyRSA

class OTPSecurityManager {
    
    private static var manager: OTPSecurityManager?

    private init() {}
    
    
    class func encryptMsg(phone:String) -> String? {
        do {
            guard let jsonString = Utils.convertDictionaryToString(["phone": phone]) else { return nil }
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
