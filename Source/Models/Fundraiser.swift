//
//  Fundraiser.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 04.01.2025.
//

import Foundation
import FirebaseFirestore

struct Fundraiser {
    let id: Int
    let title: String
    let description: String
    let jarLink: String
    let isClosed: Bool
    let closeDate: Date?
    let linkAPI: String
    
    static func createFromDocument(_ doc: QueryDocumentSnapshot) -> Fundraiser? {
        guard
            let id = Int(doc.documentID),
            let title = doc.data()["title"] as? String,
            let description = doc.data()["description"] as? String,
            let jarLink = doc.data()["jarLink"] as? String,
            let isClosed = doc.data()["isClosed"] as? Bool,
            let linkAPI = doc.data()["linkAPI"] as? String
        else {
            return nil
        }
        let closeDate = (doc.data()["closeDate"] as? Timestamp)?.dateValue()
        return Fundraiser(
            id: id,
            title: title,
            description: description,
            jarLink: jarLink,
            isClosed: isClosed,
            closeDate: closeDate,
            linkAPI: linkAPI
        )
    }
}
