//
//  Fundraiser.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 04.01.2025.
//

import Foundation

struct ListElementModel {
    let id: Int
    var title: String
    var goal: Float
    var amount: Float
    var status: Status

    enum Status {
        case open
        case closed(closeDate: Date)
    }
}
