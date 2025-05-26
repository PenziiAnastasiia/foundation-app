//
//  FundraiserListElement.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 11.01.2025.
//

import Foundation

struct FundraiserModel: Filterable {
    let id: String
    let title: String
    let description: String
    let descriptionMedia: [String]?
    let goal: Int
    let collected: Double
    let openDate: Date
    let closeDate: Date?
    let purposeTags: [String]
    
    // MARK: - Filterable
    
    var target: Int? { return self.goal }
    var date: Date { return self.openDate }
}
