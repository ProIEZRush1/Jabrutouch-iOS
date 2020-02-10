//
//  JTUserProfileParameters.swift
//  Jabrutouch
//
//  Created by yacov sofer on 15/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

class JTUserProfileParameters {
    var education: [JTUserProfileParameter] = []
    var interest: [JTUserProfileParameter] = []
    var occupation: [JTUserProfileParameter] = []
    var communities: [JTUserProfileParameter] = []
    
    init(value: [String:Any]) {
        if let educationArray = value["Education"] as? [[String: Any]] {
            self.education = educationArray.compactMap{ JTUserProfileParameter(data: $0)}
        }
        if let interestArray = value["Interest"] as? [[String: Any]] {
            self.interest = interestArray.compactMap{ JTUserProfileParameter(data: $0)}
        }
        if let occupationArray = value["Occupation"] as? [[String: Any]] {
            self.occupation = occupationArray.compactMap{ JTUserProfileParameter(data: $0)}
        }
        if let communitiesArray = value["Communities"] as? [[String: Any]] {
            self.communities = communitiesArray.compactMap{ JTUserProfileParameter(data: $0)}
        }
    }
}
