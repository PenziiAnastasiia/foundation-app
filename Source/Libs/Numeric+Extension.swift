//
//  Numeric+Extension.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 14.04.2025.
//

import Foundation


extension Numeric {
    func formattedWithSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        
        if let doubleValue = self as? Double {
            formatter.decimalSeparator = "."
            return formatter.string(from: NSNumber(value: doubleValue)) ?? "\(self)"
        } else if let intValue = self as? Int {
            return formatter.string(from: NSNumber(value: intValue)) ?? "\(self)"
        } else {
            return "\(self)"
        }
    }
}

