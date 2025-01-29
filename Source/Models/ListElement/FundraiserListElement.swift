//
//  FundraiserListElement.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 11.01.2025.
//

import Foundation

struct FundraiserListElement {
    let id: Int
    let title: String
    let goal: Int
    let amount: Double
    let closeDate: Date?
    
    public func setGoalValue(_ goal: Int) -> FundraiserListElement {
        return FundraiserListElement(
            id: self.id,
            title: self.title,
            goal: goal,
            amount: self.amount,
            closeDate: self.closeDate
        )
    }
    
    public func setAmountValue(_ amount: Double) -> FundraiserListElement {
        return FundraiserListElement(
            id: self.id,
            title: self.title,
            goal: self.goal,
            amount: amount,
            closeDate: self.closeDate
        )
    }
}
