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
        } else {
            return nil
        }
        
        if let allPostsCount = self.data["count"] as? Int {
            self.allItemsCount = allPostsCount
        } else {
            return nil
        }
        
        if let nextPage = self.data["next"] as? String {
            self.nextPageLink = nextPage
        } else {
            return nil
        }
        
        if let previousPage = self.data["previous"] as? String {
            self.previousPageLink = previousPage
        } else {
            return nil
        }
        
        if let newsItems = self.data["results"] as? [[String:Any]]  {
            self.newsFeedItems = newsItems.compactMap{JTNewsFeedItem(values: $0)}
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
