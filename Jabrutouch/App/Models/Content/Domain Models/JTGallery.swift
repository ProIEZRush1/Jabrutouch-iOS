//
//  JTGallery.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 26/11/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct JTGallery {
    
    var id: Int
    var title: String
    var order : Int
    var imageLink: String
    
    init?(values: [String:Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let title = values["title"] as? String {
            self.title = title
        } else { return nil }
        
        if let order = values["order"] as? Int {
            self.order = order
        } else { return nil }
        
        if let image = values["image"] as? String {
            self.imageLink = image
        } else { return nil }

    }
    
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["title"] = self.title
        values["order"] = self.order
        values["image"] = self.imageLink
        
        return values
    }
}
