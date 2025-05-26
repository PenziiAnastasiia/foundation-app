//
//  FiltersModel.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 24.05.2025.
//

import Foundation

struct FiltersModel {
    let purposeTags: [String]?
    let amountFrom: Double?
    let amountTo: Double?
    let state: (String, Int)?
    let dateTag: String?
    let dateFrom: Date?
    let dateTo: Date?
    
    var isEmpty: Bool {
        return self.purposeTags == nil && self.amountFrom == nil && self.amountTo == nil && self.state == nil && self.dateTag == nil && self.dateFrom == nil && self.dateTo == nil
    }
    
    static func createEmptyModel() -> FiltersModel {
        return FiltersModel(purposeTags: nil, amountFrom: nil, amountTo: nil, state: nil, dateTag: nil, dateFrom: nil, dateTo: nil)
    }
    
    func addPurposeTags(_ tags: [String]) -> FiltersModel {
        return FiltersModel(purposeTags: tags, amountFrom: self.amountFrom, amountTo: self.amountTo, state: self.state, dateTag: self.dateTag, dateFrom: self.dateFrom, dateTo: self.dateTo)
    }
    
    func addAmountBounds(from value1: Double, to value2: Double) -> FiltersModel {
        return FiltersModel(purposeTags: self.purposeTags, amountFrom: value1, amountTo: value2, state: self.state, dateTag: self.dateTag, dateFrom: self.dateFrom, dateTo: self.dateTo)
    }
    
    func addState(_ comparisonOperator: String, _ percent: Int) -> FiltersModel {
        return FiltersModel(purposeTags: self.purposeTags, amountFrom: self.amountFrom, amountTo: self.amountTo, state: (comparisonOperator, percent), dateTag: self.dateTag, dateFrom: self.dateFrom, dateTo: self.dateTo)
    }
    
    func addDateTag(_ tag: String) -> FiltersModel {
        return FiltersModel(purposeTags: self.purposeTags, amountFrom: self.amountFrom, amountTo: self.amountTo, state: self.state, dateTag: tag, dateFrom: self.dateFrom, dateTo: self.dateTo)
    }
    
    func addDateBounds(from value1: Date, to value2: Date) -> FiltersModel {
        return FiltersModel(purposeTags: self.purposeTags, amountFrom: self.amountFrom, amountTo: self.amountTo, state: self.state, dateTag: self.dateTag, dateFrom: value1, dateTo: value2)
    }
}

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
