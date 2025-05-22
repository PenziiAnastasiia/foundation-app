//
//  DonateService.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 03.05.2025.
//

import Foundation
import FirebaseFirestore

final class DonateService {
    
    static let shared = DonateService()
    
    func updateFundraiserCollectedValue(donation: DonationModel, completion: @escaping (Result<Bool, Error>) -> Void) {
        let fundraiserRef = Firestore.firestore().collection("Fundraisers").document(donation.fundraiserId)
        fundraiserRef.updateData([
            "collected": FieldValue.increment(donation.amount)
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func saveDonateToUserHistory(uid: String, donation: DonationModel, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let data = try? donation.toDictionary() else { return }
        let userRef = Firestore.firestore().collection("Users").document(uid)
        
        userRef.collection("Donations").addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func getUserDonationHistory(uid: String, completion: @escaping (Result<[DonationModel], Error>) -> Void) {
        let userRef = Firestore.firestore().collection("Users").document(uid)
        userRef.collection("Donations").getDocuments() { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let documents = snapshot?.documents {
                let donations = documents.compactMap { try? DonationModel.fromDictionary($0.data()) }
                completion(.success(donations))
            }
        }
    }
}
