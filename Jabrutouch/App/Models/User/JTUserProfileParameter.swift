//
//  JTUserProfileParameter.swift
//  Jabrutouch
//
//  Created by yacov sofer on 15/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct JTUserProfileParameter: Equatable {
    static func == (lhs: JTUserProfileParameter, rhs: JTUserProfileParameter) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: Int
    var name: String
    
    init?(data: [String: Any]) {
        guard let id = data["id"] as? Int else { return nil }
        guard let name = data["name"] as? String else { return nil}
        self.id = id
        self.name = name
    }
    
    var values: [String: Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["name"] = self.name
        return values
    }
}
