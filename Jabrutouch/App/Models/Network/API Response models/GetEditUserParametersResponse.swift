//
//  GetEditUserParametersResponse.swift
//  Jabrutouch
//
//  Created by yacov sofer on 15/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct GetEditUserParametersResponse: APIResponseModel {
    var userProfileParameters: JTUserProfileParameters
    
    init?(values: [String:Any]) {
        self.userProfileParameters = JTUserProfileParameters(value: values)
    }
}
