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
    
    static let numberOfItemsPerPage = 10
    //========================================
    // MARK: - Properties
    //========================================
    private var latestNewsItems: [JTNewsFeedItem] = []
    private var newsItems: [[JTNewsFeedItem]] = []
    
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
    }
    
    func getNewsItems(page: Int = 0, completion: (Result<[JTNewsFeedItem], Error>)->Void){
        if self.newsItems[page].count == NewsFeedRepository.numberOfItemsPerPage  { // This page is already loaded into memory and can be returned immediately.
            completion(.success(self.newsItems[page]))
            return
        }
        else {
            self.loadNewsItems(page: page, completion: completion)
        }
    }
        
    private func loadNewsItems(page: Int = 0, completion: (Result<[JTNewsFeedItem], Error>)->Void) {

        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            return
        }
        API.getNewsItemsAll(authToken: authToken) { (result) in
            switch result{
            case .success(let response):
                self.latestNewsItems = response.newsFeedItems
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
            case .failure(let error):
                print("news items error", error)
            }
        }

    }
        

    
    
    
    
    
}
