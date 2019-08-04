//
//  JTMishnaSeder.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 31/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class JTMishnaSeder {
    
    var name: String = ""
    var masechtot: [JTMishnaMasechet] = []
    var isExpanded = false
    
    init(sederName: String, masechtot: [JTMishnaMasechet]) {
        self.name = sederName
        self.masechtot = masechtot
    }
}
