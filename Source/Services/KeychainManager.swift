//
//  KeychainManager.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 21.05.2025.
//

import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    
    private init() { }
    
    func save(key: String, data: Data) {
         let query: [String: Any] = [
             kSecClass as String: kSecClassGenericPassword,
             kSecAttrAccount as String: key,
             kSecValueData as String: data,
             kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
         ]
         
         SecItemDelete(query as CFDictionary)
         SecItemAdd(query as CFDictionary, nil)
     }
    
    func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        return status == errSecSuccess ? result as? Data : nil
    }
    
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
