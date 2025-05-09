//
//  FundInfoManager.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 08.05.2025.
//


class FundInfoManager {
    static let shared = FundInfoManager()
    
    let name = "Благодійний фонд "
    let iban = "UA12345678900000000000000000000001"
    let edrpoy = "12121314"
    let bank = "АТ КБ «ПриватБанк»"
    let address = "м. Київ, просп. Берестейський, 1"

    private init() {}
}
