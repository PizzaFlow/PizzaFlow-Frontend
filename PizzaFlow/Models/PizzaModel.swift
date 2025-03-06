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
    
    var totalPrice: Double {
        price + ingredients.reduce(0) { $0 + $1.price }
    }
}
