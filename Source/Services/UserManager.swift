//
//  UserManager.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 07.05.2025.
//

import Foundation

class UserManager {
    static let shared = UserManager()
    
    private let userDefaultsKey = "currentUser"
    private let UIDDefaultsKey = "UID"
    
    private(set) var currentUser: UserModel?
    private(set) var currentUID: String?

    private init() {}

    func saveUserToDefaults(_ user: UserModel, uid: String) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: self.userDefaultsKey)
            UserDefaults.standard.set(uid, forKey: self.UIDDefaultsKey)
        }
        self.currentUser = user
        self.currentUID = uid
    }

    func loadUserFromDefaults() {
        if let uid = UserDefaults.standard.string(forKey: self.UIDDefaultsKey),
           let data = UserDefaults.standard.data(forKey: self.userDefaultsKey),
           let user = try? JSONDecoder().decode(UserModel.self, from: data) {
            self.currentUser = user
            self.currentUID = uid
        }
    }

    func clearUser() {
        UserDefaults.standard.removeObject(forKey: self.userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: self.UIDDefaultsKey)
        self.currentUser = nil
        self.currentUID = nil
    }
}
