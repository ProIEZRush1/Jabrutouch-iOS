//בס״ד
//  JTGemaraSeder.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 05/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class JTGemaraSeder {
    
    var name: String = ""
    var masechtot: [JTGemaraMasechet] = []
    var isExpanded = false
    
    init(sederName: String, masechtot: [JTGemaraMasechet]) {
        self.name = sederName
        self.masechtot = masechtot
    }
}
