//
//  Array+Extension.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 30.04.2025.
//

import Foundation

extension Array {
    
    func object(at index: Int) -> Element? {
        if index < self.count {
            return self[index]
        }
        
        return nil
    }
}
 
extension Array where Element: Equatable {
    
    mutating
    func remove(object: Element) -> Element? {
        if let index = self.firstIndex(where: { $0 == object }) {
            return self.remove(at: index)
        }
    
        return nil
    }
}
