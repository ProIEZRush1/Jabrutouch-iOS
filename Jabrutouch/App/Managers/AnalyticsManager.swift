//
//  AnalyticsManager.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 05/09/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

enum AnalyticsEventType: String {
    case watch = "watch"
    case delete = "delete"
    case download = "download"
}

enum AnalyticsEventCategory: String {
    case gemara = "Gemara"
    case mishna = "Mishna"
}
class AnalyticsManager {
    
    private static var manager: AnalyticsManager?
    
    class var shared: AnalyticsManager {
        if self.manager == nil {
            self.manager = AnalyticsManager()
        }
        return self.manager!
    }
    
    private init() {
        
    }
    
    func postEvent(eventType: AnalyticsEventType, category: AnalyticsEventCategory, mediaType: JTLessonMediaType, lessonId: Int, duration: Int64?, online: Bool?, completion: @escaping (_ result: Result<Any,JTError>)->Void ) {
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            completion(.failure(.authTokenMissing))
            return
        }
        API.postAnalyticsEvent(token: authToken, eventType: eventType.rawValue, category: category.rawValue, mediaType: mediaType.rawValue, lessonId: "\(lessonId)", duration: duration, online: online?.intValue) { (response: APIResult<PostAnalyticsEventResponse>) in
            switch response {
            case .success:
                print("SUCCESS")
                UserDefaultsProvider.shared.lessonAnalitics = nil
            case .failure(let error):
                print("ERROR: \(error)")
            }
        }
    }
}
