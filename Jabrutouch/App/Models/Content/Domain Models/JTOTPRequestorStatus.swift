//
//  JTOTPStatus.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 16/11/2022.
//  Copyright © 2022 Ravtech. All rights reserved.
//

import Foundation
enum JTOTPRequestorStatusType:Int {
    case open = 0
    case wait = 1
    case hold = 2
    case suspended = 3
}

struct JTOTPRequestorStatus{
    
    var waitSeconds: Int
    var nextRequestAllowedTime: Double
    var status: JTOTPRequestorStatusType
    var statusName: String
    var message: String

    init?(values: [String:Any]) {
        
        if let waitSeconds = values["wait_seconds"] as? Int {
            self.waitSeconds = waitSeconds
//            let date = NSDate()
//            let unixtime = date.timeIntervalSince1970
//            self.nextRequestAllowedTime = unixtime + Double(self.waitSeconds)
        } else { return nil }
        
        self.nextRequestAllowedTime = values["nextRequestAllowedTime"] as? Double ?? -1.0
        // Only set when coming from server.
        // Since server does not send "nextRequestAllowedTime"
        if self.nextRequestAllowedTime == -1.0 {
            let date = NSDate()
            let unixtime = date.timeIntervalSince1970
            self.nextRequestAllowedTime = unixtime + Double(self.waitSeconds)
        }

        if let status = JTOTPRequestorStatusType(rawValue: values["status"] as? Int ?? -1)  {
            self.status = status
        } else { return nil }

        if let statusName = values["status_name"] as? String {
            self.statusName = statusName
        } else { return nil }

        if let message = values["message"] as? String {
            self.message = message
        } else { return nil }
        
    }
    
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["wait_seconds"] = self.waitSeconds
        values["status"] = self.status.rawValue
        values["status_name"] = self.statusName
        values["message"] = self.message
        values["nextRequestAllowedTime"] = self.nextRequestAllowedTime
        return values
    }
}
