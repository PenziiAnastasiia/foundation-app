//
//  DonateService.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 03.05.2025.
//

import Foundation
import FirebaseFirestore

class DonateService {
    
    static let shared = DonateService()
    
    func updateFundraiserCollectedValue(fundraiserID: String, donationAmount: Double, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        let fundraiserRef = Firestore.firestore().collection("Fundraisers").document(fundraiserID)
        fundraiserRef.updateData([
            "collected": FieldValue.increment(donationAmount)
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
}
