//
//  DafYomiRepository.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 30/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class DafYomiRepository {
    
    private static var repo: DafYomiRepository?
    
    private init() {
        
    }
    
    class var shared: DafYomiRepository {
        if self.repo == nil {
            self.repo = DafYomiRepository()
        }
        return self.repo!
    }
    
    func getDafYomiByOffset(offset: Int) -> DafYomi? {
        let dafYomiData: Data = FilesManager.shared.getResource(resourceName: "daf_yomi", extensionName: "json")!
        let shas = Utils.convertDataToDictionary(dafYomiData)!["shas"] as! [[String:Any]]
        let dafValues = shas[offset]
        let daf = DafYomi(values: dafValues)
        return daf
    }
    
    func getTodaysDaf() -> DafYomi {
        return self.getDafYomiByOffset(offset: self.getTodaysOffset())!
    }
    
    private func getTodaysOffset() -> Int{
        let dafYomiData: Data = FilesManager.shared.getResource(resourceName: "daf_yomi", extensionName: "json")!
        let dafYomiDetails = Utils.convertDataToDictionary(dafYomiData)!["dafYomiDetails"] as! [String:Any]
        let dateStartString = dafYomiDetails["dateStart"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateStart = dateFormatter.date(from: dateStartString)!
        let today = Date()
        let dafStart = dafYomiDetails["dafStart"] as! Int
        
        let calendar = Calendar(identifier: .hebrew)
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: dateStart)
        let date2 = calendar.startOfDay(for: today)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
        let daysDiff = components.day!
        
        let offset = Int(Double(daysDiff + dafStart).truncatingRemainder(dividingBy: 2711))
        return offset
    }
}
