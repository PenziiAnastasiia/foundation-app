//
//  FundInfoManager.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 08.05.2025.
//


class FoundationInfoManager {
    static let shared = FoundationInfoManager()
    
    let name = "Назва деякого благодійного фонду"
    let iban = "UA12345678900000000000000000000001"
    let edrpoy = "12121314"
    let bank = "АТ КБ «ПриватБанк»"
    let address = "м. Київ, просп. Берестейський, 1"
    let phone = "+380987654321"
    let email = "example@fond.ua"
    let pib = "Іванов Іван Іванович"

    private init() {}
}
