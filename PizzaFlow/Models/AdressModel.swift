//
//  AdressModel.swift
//  PizzaFlow
//
//  Created by 596 on 23.03.2025.
//

import Foundation

struct Address: Identifiable, Codable {
    let id: Int
    let city: String
    let street: String
    let house: String
    let apartment: String
    let user_id: Int

    enum CodingKeys: String, CodingKey {
        case id
        case city
        case street
        case house
        case apartment
        case user_id = "user_id"
    }
}
