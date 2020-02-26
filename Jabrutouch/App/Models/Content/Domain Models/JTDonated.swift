//
//  JTDonated.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 24/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct JTDonated {
    
    var dedicationText: String
    var nameToRepresent: String
    var firstName: String
    var lastName: String
    
    init?(values: [String:Any]) {
        if let dedicationText = values["dedication_text"] as? String {
            self.dedicationText = dedicationText
        } else { return nil }
        
        if let nameToRepresent = values["name_to_represent"] as? String {
            self.nameToRepresent = nameToRepresent
        } else { return nil }
        
        if let firstName = values["first_name"] as? String {
            self.firstName = firstName
        } else { return nil }
        
        if let lastName = values["last_name"] as? String {
            self.lastName = lastName
        } else { return nil }
        
    }
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["dedication_text"] = self.dedicationText
        values["name_to_represent"] = self.nameToRepresent
        values["first_name"] = self.firstName
        values["last_name"] = self.lastName
        
        return values
    }
}
