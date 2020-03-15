//
//  DonationManager.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 09/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation

protocol DonationManagerDelegate: class {
     func userDonationDataReceived()
}

protocol DonationDataDelegate: class {
     func donationsDataReceived()
}

class DonationManager: NSObject {
    
    var userDonation: JTUserDonation?
    var donation: JTDonation?
    var crowns: [JTCrown] = []
    var dedication: [JTDedication] = []
    
    weak var donationManagerDelegate: DonationManagerDelegate?
    weak var donationDataDelegate: DonationDataDelegate?
    private static var manager: DonationManager?
    
    private override init() {
        super.init()
        self.getUserDonation()
        self.getDonationData()
    }
    
    class var shared: DonationManager {
        if self.manager == nil {
            self.manager = DonationManager()
        }
        return self.manager!
    }
    
    func getDonationData() {
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else { return }
        API.getDonationsData(authToken: authToken) { (result: APIResult<DonationResponse>) in
            switch result{
            case .success(let data):
                self.donation = data.donation
                self.dedication = data.donation.dedication
                self.crowns = data.donation.crowns
                self.donationDataDelegate?.donationsDataReceived()
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    func getUserDonation() {
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else { return }
        API.getUserDonations(authToken: authToken) { (result: APIResult<UserDonationResponse>) in
            switch result{
            case .success(let data):
                self.userDonation = data.userDonation
                self.donationManagerDelegate?.userDonationDataReceived()
                print(data)
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    func getDonationAllertData(completion:@escaping (_ result: Result<LessonDonationResponse, JTError>)->Void) {
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else { return }
        API.getLessonDonation(authToken: authToken) { (result: APIResult<LessonDonationResponse>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))

            }
        }
    }
    
    func createLike(lessonId: Int, isGemara: Bool, crownId: Int, completion:@escaping (_ result: Result<Any, JTError>)->Void) {
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else { return }
        API.createDonationLikeRequest(lessonId: lessonId, isGemara: isGemara, crownId: crownId, authToken: authToken) { (result: APIResult<CreateLikeResponse>) in
            switch result{
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))

            }
        }
    }
    
    func createPaymen(_ postDedication: JTPostDedication, completion:@escaping (_ result: Result<Any, JTError>)->Void) {
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else { return }
        let country = UserDefaultsProvider.shared.currentUser?.country ?? ""
        API.createDonationPayment(sum: postDedication.sum, paymentType: postDedication.paymentType, dedicationText: postDedication.dedicationText, status: postDedication.status, dedicationTemplate: postDedication.dedicationTemplate, nameToRepresent: postDedication.nameToRepresent, country: country, authToken: authToken) { (result: APIResult<CreatePaymentResponse>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))

            }
        }
    }
    
}
