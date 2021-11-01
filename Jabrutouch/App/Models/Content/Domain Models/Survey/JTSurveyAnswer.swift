//
//  JTSurveyAnswer.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 31/10/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import Foundation

struct JTSurveyAnswer {
    var id: Int
    var answer: String
    var order: Int
    var question: Int
    
    init?(values: [String:Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let answer = values["answer"] as? String {
            self.answer = answer
        } else { return nil }
        
        if let order = values["order"] as? Int {
            self.order = order
        } else { return nil }
        
        if let question = values["question"] as? Int {
            self.question = question
        } else { return nil }
        
    }
    
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["answer"] = self.answer
        values["order"] = self.order
        values["question"] = self.question

        return values
    }
}
