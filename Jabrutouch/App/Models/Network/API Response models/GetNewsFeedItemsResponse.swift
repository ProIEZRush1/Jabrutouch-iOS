//
//  GetNewsFeedItemsResponse.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 30/08/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import Foundation

struct GetNewsFeedItemsResponse: APIResponseModel {
    
    var data: [String:Any]
    var newsFeedItems: [JTNewsFeedItem]
    var allItemsCount: Int?
    var nextPageLink: String?
    var previousPageLink: String?
    
    
    
    init?(values: [String : Any]) {
        
        if let alldata = values["news_items"] as? [String:Any] {
            self.data = alldata
//            print("news_items", self.data)
        } else {
            return nil
        }
        
        self.allItemsCount = self.data["count"] as? Int
//        print("count", self.allItemsCount!)
        
        self.nextPageLink = self.data["next"] as? String
//        print("next", self.nextPageLink as Any)
        
        self.previousPageLink = self.data["previous"] as? String
//        print("previous", self.previousPageLink as Any)
        
        if let newsItems = self.data["results"] as? [[String:Any]]  {
//            print("newsItems", newsItems)
            self.newsFeedItems = newsItems.compactMap{JTNewsFeedItem(values: $0)}
//            print("newsFeedItems", self.newsFeedItems)
        } else {
            return nil
        }
    }

}

//"success": true,
//    "data": {
//        "news_items": {
//            "count": 19,
//            "next": "http://django-prod/api/news_feed/?limit=10&offset=10",
//            "previous": null,
//            "results": [
//                {
