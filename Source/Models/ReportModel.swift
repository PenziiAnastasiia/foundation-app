//
//  ReportModel.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 22.04.2025.
//

import Foundation

struct ReportModel {
    let id: String
    let title: String
    let description: String
    let collected: Double
    let closeDate: Date
    let reportMediaNames: [String]?
}
