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
    var user_answer_value: String
    var user: Int
    var survey: Int
    var stage: Int
    
    
    var values: [String:Any?] {
        var values: [String:Any?] = [:]
        values.updateValue(self.question, forKey: "question")
        values.updateValue(self.survey_answer, forKey: "survey_answer")
        values.updateValue(self.user_answer_value, forKey: "user_answer_value")
        values.updateValue(self.user, forKey: "user")
        values.updateValue(self.survey, forKey: "survey")
        values.updateValue(self.stage, forKey: "stage")
        return values
    }

    
}
