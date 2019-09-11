//בעזרת ה׳ החונן לאדם דעת
//  LocalizationManager.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 22/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class LocalizationManager {
    
    //====================================================
    // MARK: - Private Properties
    //====================================================
    private static var manager: LocalizationManager?
    
    //====================================================
    // MARK: - Public Properties
    //====================================================
    
    /// Shared instance of the LocalizationManager
    class var shared: LocalizationManager {
        if self.manager == nil {
            self.manager = LocalizationManager()
        }
        return self.manager!
    }
    
    private init() {
        
    }
    
    
    /// Returns a list of all the countries with their name and dial code
    ///
    /// - Returns: Array of country objects
    func getCountries() -> [Country] {
        guard let data = FilesManagementProvider.shared.getResource(resourceName: "countries", extensionName: "json") else { return [] }
        guard let json = Utils.convertDataToJSONObject(data) as? [[String:Any]] else { return [] }
        let countries = json.compactMap{Country(data: $0)}
        return countries.sorted{$0.localizedName < $1.localizedName}
    }
    
    func getDefaultCountry() -> Country? {
        let countries = self.getCountries()
        let countryCode = Locale.current.regionCode ?? ""
        return countries.first{$0.code == countryCode}
    }
    
    func getCountry(regionCode: String) -> Country? {
        let countries = self.getCountries()
        return countries.first{$0.code == regionCode}
    }
}
