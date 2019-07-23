//בעזרת ה׳ החונן לאדם דעת
//  FilesManager.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 22/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class FilesManager {
    
    private static var manager: FilesManager?
    
    class var shared: FilesManager {
        if self.manager == nil {
            self.manager = FilesManager()
        }
        return self.manager!
    }
    
    private init() {
        
    }
    
    //MARK - Public methods
    
    func getResource(resourceName: String, extensionName: String) -> Data? {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: extensionName) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return data
        }
        catch {
            return nil
        }
    }
}
