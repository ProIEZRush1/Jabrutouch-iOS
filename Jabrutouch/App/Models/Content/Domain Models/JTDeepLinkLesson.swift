//
//  JTLessonDeepLink.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 22/06/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

class JTDeepLinkLesson {
    
    
    //============================================
    // MARK: - Stored Properties
    //============================================
    var type: String
    var seder : Int
    var masechet: Int
    var page: Int?
    var video: Int
    var masechetName: String
    var gemara: Int
    var mishna: Int?
    var chapter: Int?
    
    
    //============================================
    // MARK: - Initializer
    //============================================
    
    init?(values: [String: String]) {
        
        if let type = values["type"] {
            self.type = type
        } else { return  nil }
        
        if let seder = values["seder"] {
            self.seder = Int(seder) ?? -1
        } else { return  nil }
        
        if let masechet = values["masechet"] {
            self.masechet = Int(masechet) ?? -1
        } else { return nil }
        
        if let page = values["page"]  {
            self.page = Int(page) ?? -1
        } else { page = nil }
        
        if let video = values["video"]  {
            self.video = Int(video) ?? -1
        } else { return nil }
        
        if let masechetName = values["masechet_name"]  {
            self.masechetName = masechetName
        }else { return nil }
        
        if let gemara = values["gemara"] {
            self.gemara = Int(gemara) ?? -1
            if self.gemara == 0 {
                if let mishna = values["mishna"] {
                    self.mishna = Int(mishna) ?? -1
                } else { return nil }
                if let chapter = values["chapter"] {
                    self.chapter = Int(chapter) ?? -1
                } else { return nil }
            }
            
        } else { return nil }
        
    }
    
}
