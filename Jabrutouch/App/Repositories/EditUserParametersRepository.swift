//
//  EditUserParametersRepository.swift
//  Jabrutouch
//
//  Created by yacov sofer on 15/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

protocol EditUserParametersRepositoryDelegate: class {
    func parametersLoaded(parameters: JTUserProfileParameters)
}

enum EditUserParameter {
    case email
    case country
    case phoneNumber
    case birthday
    case community
    case religious
    case education
    case occupation
    case secondEmail
}

class EditUserParametersRepository {
    var parameters: JTUserProfileParameters?
    
    weak var delegate: EditUserParametersRepositoryDelegate?
    private init() {
        self.loadParameters(completion: { result in
            switch result {
                
            case .success(let response):
                self.parameters = response
                DispatchQueue.main.async {
                    self.delegate?.parametersLoaded(parameters: response)
                }
            case .failure(let error):
                print(error.message)
            }
        })
    }
    
    static private var repository: EditUserParametersRepository?
    class var shared: EditUserParametersRepository {
        if self.repository == nil {
            self.repository = EditUserParametersRepository()
        }
        return self.repository!
    }

    private func loadParameters(completion: @escaping (_ result: Result<JTUserProfileParameters,JTError>)->Void) {
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            completion(.failure(.authTokenMissing))
            return
        }
        API.getEditUserParameters(authToken: authToken) { (result: APIResult<GetEditUserParametersResponse>) in
            switch result {
            case .success(let response):
                completion(.success(response.userProfileParameters))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
