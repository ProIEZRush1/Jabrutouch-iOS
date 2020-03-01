//
//  CreatePaymentResponse.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 01/03/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

struct CreatePaymentResponse: APIResponseModel {
    
    var id: Int
    var sum: Int
    var dayOfMonth: Int
    var numerOfPayments: Int
    var dedicationText: String
    var nameToRepresent: String
    var country: String
    var status: String
    var defaultUser: Bool
    var userId: Int
    var paymentType: Int
    var dedicationTemplate: Int
    
    init?(values: [String : Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let sum = values["sum"] as? Int {
            self.sum = sum
        } else { return nil }
        
        if let dayOfMonth = values["day_of_month"] as? Int {
            self.dayOfMonth = dayOfMonth
        } else { return nil }
        
        if let numerOfPayments = values["num_of_payments"] as? Int {
            self.numerOfPayments = numerOfPayments
        } else { return nil }
        
        if let dedicationText = values["dedication_text"] as? String {
            self.dedicationText = dedicationText
        } else { return nil }
        
        if let nameToRepresent = values["name_to_represent"] as? String {
            self.nameToRepresent = nameToRepresent
        } else { return nil }
        
        if let country = values["country"] as? String {
            self.country = country
        } else { return nil }
        
        if let status = values["status"] as? String {
            self.status = status
        } else { return nil }
        
        if let defaultUser = values["default_user"] as? Bool {
            self.defaultUser = defaultUser
        } else { return nil }
        
        if let userId = values["user_id"] as? Int {
            self.userId = userId
        } else { return nil }
        
        if let paymentType = values["payment_type"] as? Int {
            self.paymentType = paymentType
        } else { return nil }
        
        if let dedicationTemplate = values["dedication_template"] as? Int {
            self.dedicationTemplate = dedicationTemplate
        } else { return nil }
        
    }
}
