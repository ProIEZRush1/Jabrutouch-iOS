//
//  PostSurveyUserAnswersResponse.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 02/11/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import Foundation

struct PostSurveyUserAnswersResponse: APIResponseModel {
    var answers: [JTSurveyUserAnswer]?
   
    init?(values: [String : Any]) {
    }
}
