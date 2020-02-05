//
//  JTError.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 30/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

enum JTError: Error {
    case unableToConvertDictionaryToString
    case unableToConvertStringToData
    case invalidUrl
    case authTokenMissing
    case userAlreadyExist
    case unknown
    case unableToCreateRequest
    case unableToParseResponse
    case serverError(Error)
    case invalidToken
    case custom(String)
    
    var message: String {
        switch self {
        case .serverError(let error):
            return error.localizedDescription
        case .invalidToken:
            return "Invalid Token."
        case .custom(let message):
            return message
        default:
            return "Server error"
        }
    }
}
