//
//  IngridientModel.swift
//  PizzaFlow
//
//  Created by 596 on 06.03.2025.
//

import Foundation

struct Ingredient: Identifiable, Codable {
    let id: Int
    let name: String
    let price: Double
    let photo: String?
}
