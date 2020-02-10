//בעזרת ה׳ החונן לאדם דעת
//  JTCommunity.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 31/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct JTCommunity {
    var id: Int
    var name: String
    
    init?(values: [String:Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let name = values["name"] as? String {
            self.name = name
        } else { return nil }
    }
    
    init(editUserParameter: JTUserProfileParameter) {
        self.id = editUserParameter.id
        self.name = editUserParameter.name
    }
    var values: [String: Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["name"] = self.name
        return values
    }
}
