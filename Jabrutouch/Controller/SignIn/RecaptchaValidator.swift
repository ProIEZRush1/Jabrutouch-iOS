//
//  RecaptchaValidator.swift
//  Jabrutouch
//
//  Created by ECH on 10/03/25.
//  Copyright © 2025 Ravtech. All rights reserved.
//

import Foundation

struct RecaptchaValidator {
    static let url = "https://jabrutouch.overcloud.us/api/verify-recaptcha" //"https://mercadoprotest.bluemango.com.mx/api/verify-recaptcha"

    static func verifyRecaptchaToken(token: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: Self.url) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let postString = "recaptcha_token=\(token)&platform=1"
        request.httpBody = postString.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error verifying Recaptcha: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }

            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let success = jsonResponse["success"] as? Bool {
                completion(success)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
}
