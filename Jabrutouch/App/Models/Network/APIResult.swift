//בעזרת ה׳ החונן לאדם דעת
//  APIResult.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 30/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

enum APIResult<APIResponseModel> {
    case success(APIResponseModel)
    case failure(JTError)
}
