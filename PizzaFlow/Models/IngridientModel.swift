//
//  IngridientModel.swift
//  PizzaFlow
//
//  Created by 596 on 06.03.2025.
//

import Foundation

struct Ingredient: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let price: Double
    let photo: String
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        return lhs.id == rhs.id
    }
}
