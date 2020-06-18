//
//  JTPopup.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 11/06/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct JTPopup: APIResponseModel {
    
    var type: Int
    var title: String
    var subTitle: String
    var description: String
    var image: String
    
    init?(values: [String:Any]) {
        if let type = values["type"] as? Int {
            self.type = type
        } else { return nil }
        
        if let title = values["title"] as? String {
            self.title = title
        } else { self.title = "" }
        
        if let subTitle = values["sub_title"] as? String {
            self.subTitle = subTitle
        } else { self.subTitle = "" }
        
        if let description = values["description"] as? String {
            self.description = description
        } else { self.description = "" }
        
        if let image = values["image"] as? String {
            self.image = image
        } else { self.image = "" }
    }
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["type"] = self.type
        values["description"] = self.description
        values["sub_title"] = self.subTitle
        values["description"] = self.description
        values["image"] = self.image
        return values
    }
}
