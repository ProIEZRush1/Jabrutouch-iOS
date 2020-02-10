//
//  DonationManager.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 09/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

class DonationManager {
    
    private static var manager: DonationManager?
    
    private init() {
        
    }
    
    class var shared: DonationManager {
        if self.manager == nil {
            self.manager = DonationManager()
        }
        return self.manager!
    }
    
    func getDonationData(completion: @escaping (_ result: Result< JTDonation ,JTError>)->Void) {
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            completion(.failure(.authTokenMissing))
            return
        }
        API.getDonationsData(authToken: authToken) { (result: APIResult<DonationResponse>) in
            switch result{
            case .success(let data):
                completion(.success(data.donation))
                print(data)
            case .failure(let error):
                print(error)
                
            }
        }
    }
}
