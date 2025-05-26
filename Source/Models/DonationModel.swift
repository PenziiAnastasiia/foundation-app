//
//  DonateModel.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 29.04.2025.
//

import Foundation

struct DonationModel: Codable, Filterable {
    let fundraiserId: String
    let fundraiserTitle: String
    let amount: Double
    let date: Date
    let receiptNumber: Int
    let purposeTags: [String]
    
    // MARK: - Filterable
    
    var title: String { return self.fundraiserTitle }
    var target: Int? { return nil }
    var collected: Double { return self.amount }
}
