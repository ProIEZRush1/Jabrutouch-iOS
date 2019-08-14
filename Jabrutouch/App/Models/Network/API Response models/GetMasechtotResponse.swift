//בעזרת ה׳ החונן לאדם דעת
//  GetMasechtotResponse.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct GetMasechtotResponse: APIResponseModel {
    var shas: [JTSeder]
    
    init?(values: [String:Any]) {
        if let shasValues = values["seder"] as? [[String:Any]] {
            self.shas = shasValues.compactMap{JTSeder(values: $0)}
        } else { self.shas = [] }
    }
}
