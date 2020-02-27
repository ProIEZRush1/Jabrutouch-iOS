//
//  JTDedication.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 09/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct JTDedication {
    
    var id: Int
    var name: String
    
    init?(values: [String:Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let name = values["template"] as? String {
            self.name = name
        } else { return nil }
        
    }
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["template"] = self.name
        
        return values
    }
}
