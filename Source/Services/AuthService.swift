//
//  AuthService.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 08.05.2025.
//

import Foundation
import FirebaseAuth

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
        guard let uid = UserManager.shared.currentUID else { return }
        do {
            try Auth.auth().signOut()
            FirestoreService.shared.deleteFirebaseCloudMessagingToken(uid: uid)
            completion(.success(true))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteUser() {
        Auth.auth().currentUser?.delete { _ in }
    }
}
