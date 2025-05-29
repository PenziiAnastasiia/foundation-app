//
//  FirestoreService.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 27.05.2025.
//

import FirebaseFirestore
import FirebaseMessaging

final class FirestoreService {
    
    static let shared = FirestoreService()
    
    func getFundraisersList() async -> [FundraiserModel] {
        var fundraisersList: [FundraiserModel] = []
        do {
            let db = Firestore.firestore()
            let querySnapshot = try await db.collection("Fundraisers").getDocuments()
            
            for document in querySnapshot.documents {
                if let fundraiser = self.createFundraiser(from: document.data(), with: document.documentID) {
                    fundraisersList.append(fundraiser)
                }
            }
        } catch {
            debugPrint("Error fetching fundraisers data: \(error)")
        }
        return fundraisersList
    }
    
    func getReportsList() async -> [ReportModel] {
        var reportsList: [ReportModel] = []
        do {
            let db = Firestore.firestore()
            let querySnapshot = try await db.collection("Reports").getDocuments()
            
            for document in querySnapshot.documents {
                if let report = await self.createReport(from: document.data(), with: document.documentID) {
                    reportsList.append(report)
                }
            }
        } catch {
            debugPrint("Error fetching reports data: \(error)")
        }
        return reportsList
    }
    
    func saveUserData(_ uid: String, _ user: UserModel, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let data = try? user.toDictionary() else { return }
        
        Firestore.firestore().collection("Users").document(uid).setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.addFirebaseCloudMessagingToken(uid: uid)
                completion(.success(true))
            }
        }
    }
    
    func getUserData(_ uid: String) async throws -> [String: Any] {
        let document = try await Firestore.firestore().collection("Users").document(uid).getDocument()
        
        if let data = document.data() {
            self.addFirebaseCloudMessagingToken(uid: uid)
            return data
        } else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found"])
        }
    }
    
    func addFirebaseCloudMessagingToken(uid: String) {
        Messaging.messaging().token { token, error in
            if let error = error {
                debugPrint(error)
            }
            if let token = token {
                Firestore.firestore().collection("Users").document(uid).updateData(["fcmToken": token])
            }
        }
    }
    
    func deleteFirebaseCloudMessagingToken(uid: String) {
        Firestore.firestore().collection("Users").document(uid).updateData(["fcmToken": FieldValue.delete()])
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
    
    // MARK: - private
    
    private func createFundraiser(from document: [String: Any], with id: String) -> FundraiserModel? {
        guard let title = document["title"] as? String,
              let description = document["description"] as? String,
              let openDate = (document["openDate"] as? Timestamp)?.dateValue(),
              let goal = document["goal"] as? Int,
              let collected = document["collected"] as? Double,
              let purposeTags = document["purposeTags"] as? [String]
        else { return nil }
        
        let descriptionMedia = document["descriptionMedia"] as? [String]
        let closeDate = (document["closeDate"] as? Timestamp)?.dateValue()
        
        let fundraiser = FundraiserModel(id: id, title: title, description: description, descriptionMedia: descriptionMedia, goal: goal, collected: collected, openDate: openDate, closeDate: closeDate, purposeTags: purposeTags)
        
        return fundraiser
    }
    
    private func createReport(from document: [String: Any], with id: String) async -> ReportModel? {
        guard let title = document["title"] as? String,
              let description = document["description"] as? String,
              let publicationDate = (document["publicationDate"] as? Timestamp)?.dateValue(),
              let collected = document["collected"] as? Double,
              let purposeTags = document["purposeTags"] as? [String]
        else { return nil }
        
        let reportMedia = document["reportMedia"] as? [String]
        
        let report = ReportModel(id: id, title: title, description: description, collected: collected, publicationDate: publicationDate, reportMedia: reportMedia, purposeTags: purposeTags)
        
        return report
    }
}
