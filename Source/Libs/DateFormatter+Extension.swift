//
//  DateFormatter+Extension.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 29.04.2025.
//

import Foundation

extension DateFormatter {
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

