//
//  User.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 07.05.2025.
//

struct UserModel: Codable {
    let PIB: String
    let emoji: String
    let type: String

    // Тільки для legal
    let organizationName: String?
    let EDRPOY: String?
    let IBAN: String?
    let bank: String?
    let address: String?
    let phoneNumber: String?
}

struct PublicUserDataModel: Codable {
    let emoji: String
    let type: String

    // Тільки для legal
    let organizationName: String?
    let EDRPOY: String?
    let bank: String?
    let address: String?
}
