//
//  PizzaModel.swift
//  PizzaFlow
//
//  Created by 596 on 05.03.2025.
//
import Foundation

struct Pizza: Codable, Identifiable {
    let id: Int
    let name: String
    let price: Double
    let description: String
    let photo: String
    let ingredients: [Ingredient]
    var quantity: Int = 1
    
    enum CodingKeys: String, CodingKey {
        case id, name, price, description, photo, ingredients
    }
    var totalPrice: Double {
        price + ingredients.reduce(0) { $0 + $1.price }
    }
}
