//
//  NewsFeedRepository.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 30/08/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import Foundation

enum JTNewsFeedMediaType: String {
    case audio = "audio"
    case video = "video"
    case image = "image"
    case noMedia = ""
}

class NewsFeedRepository{
    
    //========================================
    // MARK: - Properties
    //========================================
    

    private static var repository: NewsFeedRepository?
    
    var totalPostsInDataBase: Int = 0

    class var shared: NewsFeedRepository {
        if self.repository == nil {
            self.repository = NewsFeedRepository()
        }
        return self.repository!
    }
    
    //========================================
    // MARK: - Initializer
    //========================================
    
    private init() {
    }
         
    func getAllNewsItems(offSet: String?, completionHandler: @escaping(_ response: [JTNewsFeedItem])->Void ){

        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            return
        }
        API.getNewsItemsAll(authToken: authToken, offSet: offSet) { (result) in
            switch result {
            case .success(let response):
                self.totalPostsInDataBase = response.allItemsCount ?? 0
                completionHandler(response.newsFeedItems)
            case .failure(let error):
                print("news items error", error)
            }
        }

    }
    

    func getLatestNewsItems(completionHandler: @escaping(_ response: [JTNewsFeedItem])->Void ){

        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            return
        }
        API.getNewsItemsLatest(authToken: authToken) { (result: APIResult<GetNewsFeedItemsResponse>) in
            switch result{
            case .success(let response):
                if response.newsFeedItems.isEmpty {
                    completionHandler(UserDefaultsProvider.shared.latestNewsItems ?? [])
                } else {
                    UserDefaultsProvider.shared.latestNewsItems = response.newsFeedItems
                    completionHandler(UserDefaultsProvider.shared.latestNewsItems ?? [])
                }
                print("getLatestNewsItems() latestNewsItems", response.newsFeedItems)
            case .failure(let error):
                completionHandler(UserDefaultsProvider.shared.latestNewsItems ?? [])
                print("getLatestNewsItems() error", error)
            }
        }

    }
    
    
    
    
}
