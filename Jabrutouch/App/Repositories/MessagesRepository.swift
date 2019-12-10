//
//  MessagesRepository.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 10/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation


class MessagesRepository {
    
    static private var manager: MessagesRepository?
    
    class var shared: MessagesRepository {
        if self.manager == nil {
            self.manager = MessagesRepository()
        }
        return self.manager!
    }
}
