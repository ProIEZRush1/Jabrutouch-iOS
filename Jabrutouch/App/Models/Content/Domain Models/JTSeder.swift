//בעזרת ה׳ החונן לאדם דעת
//  JTSeder.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 13/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct JTSeder {
    
    var id: Int
    var order: Int
    var name: String
    var masechtot: [JTMasechet]
    
    init?(values: [String:Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let order = values["order"] as? Int {
            self.order = order
        } else { return nil }
        
        if let name = values["name"] as? String {
            self.name = name
        } else { return nil }
        
        if let masechtotValues = values["masechet"] as? [[String: Any]] {
            self.masechtot = masechtotValues.compactMap{JTMasechet(values: $0)}
        } else { self.masechtot = [] }
    }
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["order"] = self.order
        values["name"] = self.name
        values["masechet"] = self.masechtot.map{$0.values}
        return values
    }
}
