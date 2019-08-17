//בעזרת ה׳ החונן לאדם דעת
//  JTLessonPresenter.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct JTLesssonPresenter {
    
    var id: Int
    var firstName: String
    var lastName: String
    var phone: String
    var imageLink: String
    
    init?(values: [String:Any]) {
        
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let firstName = values["first_name"] as? String {
            self.firstName = firstName
        } else { return nil }
        
        if let lastName = values["phone"] as? String {
            self.lastName = lastName
        } else { return nil }
        
        if let phone = values["phone"] as? String {
            self.phone = phone
        } else { return nil }
        
        if let imageLink = values["image"] as? String {
            self.imageLink = imageLink
        } else { return nil }

    }
}


