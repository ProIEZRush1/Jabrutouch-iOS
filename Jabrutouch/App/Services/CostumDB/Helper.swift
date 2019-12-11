//
//  Helper.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 11/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

let DirectoryUrl = getDocumentsDirectory().appendingPathComponent("SQLiteApp").resolvingSymlinksInPath

private enum Database: String {
    case DynamicMessageTablesDB
    case DynamicGroupsTablesDB
    case DynamicMessageIdTablesDB
    
    var path: String {
        return DirectoryUrl().appendingPathComponent("\(self.rawValue).sqlite").relativePath
    }
}

public let dynamicMessageTablesDB = Database.DynamicMessageTablesDB.path
public let dynamicGroupsTablesDB = Database.DynamicGroupsTablesDB.path
public let dynamicMessageIdTablesDB = Database.DynamicMessageIdTablesDB.path


private func destroyDatabase(db: Database) {
  do {
    if FileManager.default.fileExists(atPath: db.path) {
      try FileManager.default.removeItem(atPath: db.path)
    }
  } catch {
    print("Could not destroy \(db) Database file.")
  }
}

private func getDocumentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

private var SQLiteDirectory: URL? {
    return getDocumentsDirectory().appendingPathComponent("SQLiteApp")
}

func createDirectoriesIfNotExist() {
    let fileManager = FileManager()
    guard let sqliteDirectory = SQLiteDirectory else { return }
    do {
        try fileManager.createDirectory(at: sqliteDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    catch let error {
        print("Failed creating directories, with error: \(error.localizedDescription)")
    }
}


public func destroyDynamicMessageTables() {
  destroyDatabase(db: .DynamicMessageTablesDB)
}

public func destroyDynamicGroupsTables() {
  destroyDatabase(db: .DynamicGroupsTablesDB)
}
public func destroyDynamicMessageIdTables() {
    destroyDatabase(db: .DynamicMessageIdTablesDB)
}
