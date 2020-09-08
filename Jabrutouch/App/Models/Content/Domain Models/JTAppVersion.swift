//
//  JTAppVersion.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 08/09/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct JTAppVersion: APIResponseModel {
    
    var lastVersion: Bool = false
    
    init?(values: [String:Any]) {
        if let lastVersion = values["last_version"] as? Bool {
            self.lastVersion = lastVersion
        } else { return nil }
    }
    
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["last_version"] = self.lastVersion
        return values
    }
}
