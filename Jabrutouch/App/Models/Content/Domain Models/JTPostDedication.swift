//
//  JTPostDedication.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 09/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

class JTPostDedication {
    
    var sum: Int
    var paymentType: Int
    var nameToRepresent: String
    var dedicationText: String
    var status: String
    var dedicationTemplate: Int
    
    init(sum: Int, paymenType: Int, nameToRepresent: String, dedicationText: String, status: String, dedicationTemplate: Int){
        self.sum = sum
        self.paymentType = paymenType
        self.nameToRepresent = nameToRepresent
        self.dedicationText = dedicationText
        self.status = status
        self.dedicationTemplate = dedicationTemplate
    }
//    init?(values: [String:Any]) {
//        if let sum = values["sum"] as? Int {
//            self.sum = sum
//        } else { return nil }
//
//        if let paymenType = values["paymen_type"] as? Int {
//            self.paymenType = paymenType
//        } else { return nil }
//
//        if let nameToRepresent = values["name_to_represent"] as? String {
//            self.nameToRepresent = nameToRepresent
//        } else { return nil }
//
//        if let dedicationText = values["dedication_text"] as? String {
//            self.dedicationText = dedicationText
//        } else { return nil }
//
//        if let status = values["status"] as? String {
//            self.status = status
//        } else { return nil }
//
//        if let dedicationTemplate = values["dedication_template"] as? Int {
//            self.dedicationTemplate = dedicationTemplate
//        } else { return nil }
//
//    }
//
//    var values: [String:Any] {
//        var values: [String:Any] = [:]
//        values["sum"] = self.sum
//        values["paymen_type"] = self.paymenType
//        values["name_to_represent"] = self.nameToRepresent
//        values["dedication_text"] = self.dedicationText
//        values["status"] = self.status
//        values["dedication_template"] = self.dedicationTemplate
//
//        return values
//    }
}
