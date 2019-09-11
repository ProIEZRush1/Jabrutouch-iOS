//בעזרת ה׳ החונן לאדם דעת
//  DafYomi.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 30/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct DafYomi {
    var seder: String
    var masechet: String
    var offset: Int
    var daf: Int
    
    init?(values: [String:Any]) {
        if let seder = values["seder"] as? String {
            self.seder = seder
        } else { return nil }
        
        if let masechet = values["masechet"] as? String {
            self.masechet = masechet
        } else { return nil }
        
        if let offset = values["offset"] as? Int {
            self.offset = offset
        } else { return nil }
        
        if let daf = values["daf"] as? Int {
            self.daf = daf
        } else { return nil }
    }
    
    var displayString: String {
        return "\(self.masechet) \(self.daf)"
    }
    var values: [String:Any] {
        return [
            "seder": seder,
            "masechet" : masechet,
            "offset": offset,
            "daf": daf
        ]
    }
}
