//בעזרת ה׳ החונן לאדם דעת
//  FilesManagementProvider.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 22/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

enum FileDirectory {
    case cache
    case documents
    
    var url: URL? {
        switch self {
        case .cache:
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        case .documents:
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        }
    }
    
}

class FilesManagementProvider {
    
    private static var manager: FilesManagementProvider?
    
   
    
    class var shared: FilesManagementProvider {
        if self.manager == nil {
            self.manager = FilesManagementProvider()
        }
        return self.manager!
    }
    
    private init() {
        
    }
    
    //MARK - Public methods
    
    func clearDirectory(_ directory: FileDirectory) {
        guard let directoryUrl = directory.url else { return }
        
        do {
            let filesPaths = try FileManager.default.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
            for path in filesPaths {
                try FileManager.default.removeItem(at: path)
            }
        }
        catch {
            return
        }
    }
    
    func filesList(_ directory: FileDirectory) -> [String]? {
        guard let directoryUrl = directory.url else { return nil }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
            let filesNames = files.map{$0.lastPathComponent}
            return filesNames
        }
        catch {
            return nil
        }
    }
    
    func removeFiles(_ urls: [URL], completion: (URL, Result<Void,Error>)->Void) {
        for url in urls {
            do {
                try FileManager.default.removeItem(at: url)
                completion(url, .success(()) )
            }
            catch let error{
                completion(url, .failure(error))
            }
        }
    }
    
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
    
    func isFileExist(atUrl url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.absoluteString)
    }
    
    //2813_aud.mp3
    func loadFile(link: String, directory: FileDirectory) {
        
    }
    // MARK: - Private methods
    
    
    func removeFile(atPath path:URL) throws {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: path)
        }
        catch let error  {
            throw error
        }
    }
    
    func overwriteFile(path:URL, data: Data) throws {
        if self.isFileExist(atUrl: path) {
            do {
                try self.removeFile(atPath: path)
            }
            catch let error {
                throw error
            }
        }
        
        do {
            try data.write(to: path)
        }
        catch let error {
            throw error
        }
    }
    
    
}
