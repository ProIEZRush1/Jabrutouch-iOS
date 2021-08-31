//
//  JTNewsFeedItem.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 30/08/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import Foundation

struct JTNewsFeedItem {
    
    var id: Int
    var createdDate: String
    var updatedDate : String
    var mediaType: JTNewsFeedMediaType
    var mediaLink: String?
    var body: String?
    var publishDate: String?
    var publisherId: Int?
    
    
    init?(values: [String:Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let createdDate = values["created"] as? String {
            self.createdDate = createdDate
        } else { return nil }
        
        if let updatedDate = values["updated"] as? String {
            self.updatedDate = updatedDate
        } else { return nil }
        
        self.mediaType = JTNewsFeedMediaType(rawValue: (values["media_type"] as? String) ?? "") ?? .noMedia
        
        self.mediaLink = values["media_link"] as? String
        
        self.body = values["body"] as? String
        
        self.publishDate = values["publish_date"] as? String
        
        self.publisherId = values["publisher"] as? Int
    }
    
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["createdDate"] = self.createdDate
        values["updatedDate"] = self.updatedDate
        values["mediaType"] = self.mediaType.rawValue
        values["mediaLink"] = self.mediaLink
        values["body"] = self.body
        values["publishDate"] = self.publishDate
        values["publisherId"] = self.publisherId
        
        return values
    }
}
