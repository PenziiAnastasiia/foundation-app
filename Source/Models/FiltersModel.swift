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
