//בעזרת ה׳ החונן לאדם דעת
//  Country.swift
//  WideBridgeAPP
//
//  Created by Yoni Reiss on 02/06/2019.
//  Copyright © 2019 Elbit Systems. All rights reserved.
//

import Foundation

struct Country {
    
    var name: String
    var dialCode: String
    var code: String
    
    var localizedName: String {
        return Locale.current.localizedString(forRegionCode: self.code) ?? ""
    }
    
    var flag: String {
        let base = 127397
        var usv = String.UnicodeScalarView()
        for i in self.code.utf16 {
            if let scalar = UnicodeScalar(base + Int(i)) {
                usv.append(scalar)
            }            
        }
        return String(usv)
    }
    
    var fullDisplayName: String {
        return "\(self.flag) \(self.localizedName) (\(self.dialCode))"
    }
    
    private enum Keys: String {
        case name = "name"
        case dialCode = "dial_code"
        case code = "code"
    }
        
    init?(data: [String:Any]) {
        if let name = data[Keys.name.rawValue] as? String {
            self.name = name
        } else { return nil }
        
        if let dialCode = data[Keys.dialCode.rawValue] as? String {
            self.dialCode = dialCode
        } else { return nil }
        
        if let code = data[Keys.code.rawValue] as? String {
            self.code = code
        } else { return nil }
    }
}
