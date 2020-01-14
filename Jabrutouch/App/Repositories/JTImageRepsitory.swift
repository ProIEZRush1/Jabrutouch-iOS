//
//  JTImageRepsitory.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 18/11/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation


class JTImageRepsitory {
    
    static private var manager: JTImageRepsitory?
    
    class var shared: JTImageRepsitory {
        if self.manager == nil {
            self.manager = JTImageRepsitory()
        }
        return self.manager!
    }
}
