//
//  APIError.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 30/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

enum APIError: Error {
    case userAlreadyExist
    case unknown
    case unableToCreateRequest
    case unableToParseResponse
    case serverError(Error)
}
