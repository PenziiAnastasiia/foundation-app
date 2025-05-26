//
//  ReportModel.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 22.04.2025.
//

import Foundation

struct ReportModel: Filterable {
    var id: String
    let title: String
    let description: String
    let collected: Double
    let publicationDate: Date
    let reportMedia: [String]?
    let purposeTags: [String]
    
    // MARK: - Filterable
    
    var target: Int? { return nil }
    var date: Date { return publicationDate }
}
