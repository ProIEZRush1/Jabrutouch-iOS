//
//  JTSurveyQuestion.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 31/10/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import Foundation

class JTSurveyQuestionWithAnswerOptions {

    var id: Int
    var survey: Int
    var stage: Int
    var question: String
    var answer_type: JTSurveyAnswerType
    var question_number: Int
    var profile_column_name: String?
    var answer_options: [JTSurveyAnswer]
    
    
    init?(values: [String:Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let survey = values["survey"] as? Int {
            self.survey = survey
        } else { return nil }
        
        if let stage = values["stage"] as? Int {
            self.stage = stage
        } else { return nil }
        
        if let question = values["question"] as? String {
            self.question = question
        } else { return nil }
        
        if let type = JTSurveyAnswerType(rawValue: values["answer_type"] as? String ?? "") {
            self.answer_type = type
        } else { return nil }
        
        if let question_number = values["question_number"] as? Int {
            self.question_number = question_number
        } else { return nil }
        
        self.profile_column_name = values["profile_column_name"] as? String
        
        if let answer_options = values["answer_options"] as? [[String: Any]] {
            self.answer_options = answer_options.compactMap{JTSurveyAnswer(values: $0)}
        } else { return nil }
    }
    
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["survey"] = self.survey
        values["question"] = self.question
        values["answer_type"] = self.answer_type.rawValue
        values["question_number"] = self.question_number
        values["profile_column_name"] = self.profile_column_name
        values["answer_options"] = self.answer_options.map{$0.values}
        
        return values
    }
}
