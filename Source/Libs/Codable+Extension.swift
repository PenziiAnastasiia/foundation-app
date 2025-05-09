//
//  Codable+Extension.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 08.05.2025.
//

import Foundation

extension Encodable {
    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let dict = try JSONSerialization.jsonObject(with: data, options: [])
        guard let result = dict as? [String: Any] else {
            throw NSError(domain: "CodableError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Не вдалося перетворити в словник"])
        }
        return result
    }
}

extension Decodable {
    static func fromDictionary(_ dict: [String: Any]) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: dict, options: [])
        return try JSONDecoder().decode(Self.self, from: data)
    }
}
