//
//  JTSurveyUserAnswer.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 31/10/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import Foundation

struct JTSurveyUserAnswer {
    var question: Int
    var survey_answer: Int?
    var user_answer_value: String?
    var user: Int
    var survey: Int
    var stage: Int
    
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["question"] = self.question
        values["survey_answer"] = self.survey_answer
        values["user_answer_value"] = self.user_answer_value
        values["user"] = self.user
        values["survey"] = self.survey
        values["stage"] = self.stage
        return values
    }

    
}
