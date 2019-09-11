//בס״ד
//  JTDownloadGroup.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 24/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class JTDownloadGroup {
    
    var name: String = ""
    var downloads: [JTDownload]
    var isExpanded = true
    
    init(group: String, downloads: [JTDownload]?) {
        self.name = group
        self.downloads = downloads ?? []
    }
}
