//
//  UserManager.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 07.05.2025.
//

import Foundation

final class UserManager {
    
    static let shared = UserManager()
    
    private let keychainManager = KeychainManager.shared
    
    private let pibKeychainKey = "user_pib"
    private let ibanKeychainKey = "user_iban"
    private let phoneKeychainKey = "user_phone"
    
    private let publicDataUserDefaultsKey = "currentUser"
    private let UIDDefaultsKey = "UID"
    
    private(set) var currentUser: UserModel?
    private(set) var currentUID: String?

    private init() {}

    func saveUserData(_ user: UserModel, uid: String) {
        if let pibData = user.PIB.data(using: .utf8) {
            self.keychainManager.save(key: self.pibKeychainKey, data: pibData)
        }
        
        if let iban = user.IBAN, let ibanData = iban.data(using: .utf8) {
            self.keychainManager.save(key: self.ibanKeychainKey, data: ibanData)
        }
        
        if let phone = user.phoneNumber, let phoneData = phone.data(using: .utf8) {
            self.keychainManager.save(key: self.phoneKeychainKey, data: phoneData)
        }
        
        let publicData = PublicUserDataModel(
            emoji: user.emoji,
            type: user.type,
            organizationName: user.organizationName,
            EDRPOY: user.EDRPOY,
            bank: user.bank,
            address: user.address
        )
        
        if let data = try? JSONEncoder().encode(publicData) {
            UserDefaults.standard.set(data, forKey: self.publicDataUserDefaultsKey)
            UserDefaults.standard.set(uid, forKey: self.UIDDefaultsKey)
        }
        self.currentUser = user
        self.currentUID = uid
    }

    func loadUserData() {
        guard let uid = UserDefaults.standard.string(forKey: self.UIDDefaultsKey),
              let publicDataRaw = UserDefaults.standard.data(forKey: self.publicDataUserDefaultsKey),
              let publicData = try? JSONDecoder().decode(PublicUserDataModel.self, from: publicDataRaw)
        else { return }
        
        let pib = self.keychainManager.load(key: self.pibKeychainKey)
            .flatMap { String(data: $0, encoding: .utf8) } ?? ""
        
        let iban = self.keychainManager.load(key: self.ibanKeychainKey)
            .flatMap { String(data: $0, encoding: .utf8) }
        
        let phone = self.keychainManager.load(key: self.phoneKeychainKey)
            .flatMap { String(data: $0, encoding: .utf8) }
        
        let user = UserModel(
            PIB: pib,
            emoji: publicData.emoji,
            type: publicData.type,
            organizationName: publicData.organizationName,
            EDRPOY: publicData.EDRPOY,
            IBAN: iban,
            bank: publicData.bank,
            address: publicData.address,
            phoneNumber: phone
        )
        
        self.currentUser = user
        self.currentUID = uid
    }

    func clearUser() {
        self.keychainManager.delete(key: self.pibKeychainKey)
        self.keychainManager.delete(key: self.ibanKeychainKey)
        self.keychainManager.delete(key: self.phoneKeychainKey)
        
        UserDefaults.standard.removeObject(forKey: self.publicDataUserDefaultsKey)
        UserDefaults.standard.removeObject(forKey: self.UIDDefaultsKey)
        self.currentUser = nil
        self.currentUID = nil
    }
}
