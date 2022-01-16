//
//  GetSurveyUserStatusResponse.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 31/10/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import Foundation

struct GetSurveyUserStatusResponse: APIResponseModel {
        
    var user: Int?
    var survey_id: Int?
    var survey_title: String?
    var next_stage: Int?
    var stage_description: String?
    var is_active: Bool?
    var times_displayed: Int?
    var date_to_display: Date?
    var questions: [JTSurveyQuestionWithAnswerOptions]?
    
    
    
    
    
    init?(values: [String : Any]) {
        
        if let user = values["user"] as? Int {
            self.user = user
        } else {
            return nil
        }
        
        if let survey_id = values["survey_id"] as? Int {
            self.survey_id = survey_id
        } else {
            return nil
        }
        
        if let survey_title = values["survey_title"] as? String {
            self.survey_title = survey_title
        } else {
            return nil
        }
        
        if let next_stage = values["next_stage"] as? Int {
            self.next_stage = next_stage
        } else {
            return nil
        }
        
        if let stage_description = values["stage_description"] as? String {
            self.stage_description = stage_description
        } else {
            return nil
        }
        
        if let is_active = values["is_active"] as? Bool {
            self.is_active = is_active
        } else {
            return nil
        }
        
        if let times_displayed = values["times_displayed"] as? Int {
            self.times_displayed = times_displayed
        } else {
            return nil
        }
        
        guard let dateString = values["date_to_display"] as? String else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: dateString) {
            self.date_to_display = date
        } else { return nil }
        
        if let questions = values["questions"] as? [[String:Any]]  {
            self.questions = questions.compactMap{JTSurveyQuestionWithAnswerOptions(values: $0)}
        } else {
            return nil
        }
    }

}


//    "success": true,
//    "data": {
//        "user": 197,
//        "survey_id": 1,
//        "survey_title": "test1 title",
//        "next_stage": 2,
//        "stage_description": "survey 1 stage 2",
//        "is_active": true,
//        "times_displayed": 0,
//        "date_to_display": "2021-10-26 10:22:10",
//        "questions": [
//            {
//                "id": 3,
//                "survey": 1,
//                "stage": 2,
//                "question": "How are you today sir?",
//                "answer_type": "dropdown",
//                "question_number": 1,
//                "profile_column_name": "",
//                "answer_options": [
//                    {
//                        "id": 7,
//                        "created": "2021-10-26 12:42:52",
//                        "updated": "2021-10-26 12:42:53",
//                        "answer": "Ok fine",
//                        "order": 1,
//                        "question": 3
//                    },
//                    {
//                        "id": 8,
//                        "created": "2021-10-26 12:42:52",
//                        "updated": "2021-10-26 12:42:53",
//                        "answer": "Great",
//                        "order": 2,
//                        "question": 3
//                    },
//                    {
//                        "id": 9,
//                        "created": "2021-10-26 12:42:52",
//                        "updated": "2021-10-26 12:42:53",
//                        "answer": "Amazing",
//                        "order": 3,
//                        "question": 3
//                    }
//                ]
//            }
//        ]
//    }

