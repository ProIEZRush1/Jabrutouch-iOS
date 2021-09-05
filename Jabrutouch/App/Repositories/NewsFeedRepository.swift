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
    private var newsItems: [JTNewsFeedItem] = []
    private var totalItemsOnDatabase: Int = 0
    
    private static var repository: NewsFeedRepository?
    
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
        self.loadNewsItems(offSet: nil)
    }
    
    func getAllNewsItems(offSet: Int?)->[JTNewsFeedItem]{
        if self.newsItems.isEmpty || offSet != nil {
            // No pages saved yet, or need to get next page.
            self.loadNewsItems(offSet: offSet)
            return self.newsItems
        }
        else {
            // This page is already loaded into memory and can be returned immediately.
            return self.newsItems
        }
    }
        
    private func loadNewsItems(offSet: Int?) {

        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            return
        }
        API.getNewsItemsAll(authToken: authToken) { (result) in
            switch result {
            case .success(let response):
                self.newsItems += response.newsFeedItems
                if let newCount = response.allItemsCount{
                    if self.totalItemsOnDatabase != newCount {
                        // MARK: Todo - refresh list since there are new posts.
                    }
                    self.totalItemsOnDatabase = newCount
                }
                print("loadNewsItems() success ", self.latestNewsItems)
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
