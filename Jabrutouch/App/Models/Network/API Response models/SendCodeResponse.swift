//בעזרת ה׳ החונן לאדם דעת
//  SendCodeResponse.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 29/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct SendCodeResponse: APIResponseModel {
//    init?(values: [String : Any]) {
//
//    }
    
    var otpRequestorStatus: JTOTPRequestorStatus
    
    init?(values: [String:Any]) {
        if let sendCodeStatus = JTOTPRequestorStatus(values: values) {
            self.otpRequestorStatus = sendCodeStatus
        } else { return nil }

    }
}
