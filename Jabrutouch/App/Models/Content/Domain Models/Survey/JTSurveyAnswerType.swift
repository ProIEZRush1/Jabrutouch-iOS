//
//  JTSurveyAnswerType.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 31/10/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import Foundation

enum JTSurveyAnswerType: String {
    case picker = "dropdown"
    case multipleSelectionCheckbox = "checklist_mult_select"
    case ratingBar = "rating_bar"
    case singleSelectionCheckboxWithOther = "checklist_single_select_with_other"
}
