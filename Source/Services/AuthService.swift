//
//  AuthService.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 08.05.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthService {
    
    static let shared = AuthService()
    
    func signUp(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                completion(.success(result.user.uid))
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                completion(.success(result.user.uid))
            }
        }
    }
    
    func signOut(completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(true))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteUser() {
        Auth.auth().currentUser?.delete { _ in }
    }
    
    func saveUserData(_ uid: String, _ user: UserModel, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let data = try? user.toDictionary() else { return }
        
        Firestore.firestore().collection("Users").document(uid).setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func getUserData(_ uid: String) async throws -> [String: Any] {
        let document = try await Firestore.firestore().collection("Users").document(uid).getDocument()
        
        if let data = document.data() {
            return data
        } else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found"])
        }
    }

}
