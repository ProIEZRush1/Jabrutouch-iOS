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
    private var latestNewsItems: [JTNewsFeedItem] = []
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
        self.loadLatestNewsItems()
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
    
    private func loadLatestNewsItems() {

        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            return
        }
        API.getNewsItemsLatest(authToken: authToken) { (result: APIResult<GetNewsFeedItemsResponse>) in
            switch result{
            case .success(let response):
                self.latestNewsItems = response.newsFeedItems
                print("loadLatestNewsItems() latestNewsItems", self.latestNewsItems)
            case .failure(let error):
                print("loadLatestNewsItems() error", error)
            }
        }

    }

    
    
    
    
    
}
