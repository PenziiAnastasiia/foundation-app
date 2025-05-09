//
//  User.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 07.05.2025.
//

struct UserModel: Codable {
    let PIB: String
    let type: String

    // Тільки для legal
    let organizationName: String?
    let EDRPOY: String?
    let IBAN: String?
    let bank: String?
    let address: String?
    let phoneNumber: String?
    
    init(PIB: String, type: String, organizationName: String?, EDRPOY: String?, IBAN: String?, bank: String?, address: String?, phoneNumber: String?) {
        self.PIB = PIB
        self.type = type
        self.organizationName = organizationName
        self.EDRPOY = EDRPOY
        self.IBAN = IBAN
        self.bank = bank
        self.address = address
        self.phoneNumber = phoneNumber
    }
    
    init(PIB: String, type: String) {
        self.PIB = PIB
        self.type = type
        self.organizationName = nil
        self.EDRPOY = nil
        self.IBAN = nil
        self.bank = nil
        self.address = nil
        self.phoneNumber = nil
    }
}
