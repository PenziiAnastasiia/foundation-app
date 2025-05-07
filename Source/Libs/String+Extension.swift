//
//  String+Extension.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 05.05.2025.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex?.firstMatch(in: self, options: [], range: range) != nil
    }
}
