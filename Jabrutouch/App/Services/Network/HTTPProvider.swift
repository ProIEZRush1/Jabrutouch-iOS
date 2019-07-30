//בעזרת ה׳ החונן לאדם דעת
//  HTTPProvider.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 29/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

enum HttpRequestMethod:String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}


class HttpProvider {
    
    class func excecuteRequest(request:URLRequest, completionHandler:@escaping ((Data?, URLResponse?, Error?) -> Void) ) {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let _error = error {
                completionHandler(data, response, _error)
            }
            else {
                completionHandler(data, response, nil)
            }
            
        }
        task.resume()
    }
    
}
