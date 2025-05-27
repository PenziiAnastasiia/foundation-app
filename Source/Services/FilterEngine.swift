//
//  FilterEngine.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 27.05.2025.
//

import Foundation

protocol Filterable {
    var title: String { get }
    var target: Int? { get }
    var collected: Double { get }
    var date: Date { get }
    var purposeTags: [String] { get }
}

struct FilterEngine {
    static func matchesFilters<T: Filterable>(_ item: T, filters: FiltersModel) -> Bool {
        if let purposeTags = filters.purposeTags {
            let matches = item.purposeTags.contains { purposeTags.contains($0) }
            if !matches {
                return false
            }
        }
        
        if let amountFrom = filters.amountFrom,
           let amountTo = filters.amountTo {
            let amount = item.target != nil ? Double(item.target!) : item.collected
            if !(amountFrom < amount && amount < amountTo) {
                return false
            }
        }
        
        if let (comparisonOperator, percent) = filters.state {
            guard let target = item.target else { return false }
            
            let fundraiserState = Int(item.collected / Double(target) * 100)
            if (comparisonOperator == "від" && fundraiserState < percent) ||
                (comparisonOperator == "до" && fundraiserState > percent) {
                return false
            }
        }
        
        if let dateTag = filters.dateTag {
            let calendar = Calendar.current
            let now = Date()
            
            switch dateTag {
            case "Сьогодні":
                return calendar.isDate(item.date, inSameDayAs: now)

            case "За останні 7 днів":
                if let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) {
                    return item.date >= sevenDaysAgo
                }

            case "За останній місяць":
                if let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now) {
                    return item.date >= oneMonthAgo
                }

            case "В цьому році":
                let fundraiserYear = calendar.component(.year, from: item.date)
                let currentYear = calendar.component(.year, from: now)
                return fundraiserYear == currentYear

            default:
                return false
            }
        }
        
        if let dateFrom = filters.dateFrom,
           let dateTo = filters.dateTo,
           !(dateFrom < item.date && item.date < dateTo) {
            return false
        }
        
        return true
    }
}
