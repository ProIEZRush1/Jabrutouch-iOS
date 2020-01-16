//
//  JTUserProfileParameter.swift
//  Jabrutouch
//
//  Created by yacov sofer on 15/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct JTUserProfileParameter {
    var id: Int
    var name: String
    
    init?(data: [String: Any]) {
        guard let id = data["id"] as? Int else { return nil }
        guard let name = data["name"] as? String else { return nil}
        self.id = id
        self.name = name
    }
}
