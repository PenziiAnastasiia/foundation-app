//
//  DonateModel.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 29.04.2025.
//

import Foundation

struct DonationModel: Codable {
    let fundraiserId: String
    let fundraiserTitle: String
    let amount: Double
    let date: Date
    let receiptNumber: Int
}
