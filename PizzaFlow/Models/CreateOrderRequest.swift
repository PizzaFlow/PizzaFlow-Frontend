//
//  CreateOrderRequest.swift
//  PizzaFlow
//
//  Created by 596 on 07.04.2025.
//

import Foundation

struct CreateOrderRequest: Encodable {
    let addressId: Int
    let pizzas: [OrderPizzaRequest]
    let deliveryTime: String
    let paymentMethod: String
    
    enum CodingKeys: String, CodingKey {
        case addressId = "address_id"
        case pizzas
        case deliveryTime = "delivery_time"
        case paymentMethod = "payment_method"
    }
}

struct OrderPizzaRequest: Encodable {
    let pizzaId: Int
    let ingredients: [OrderIngredientRequest]
    
    enum CodingKeys: String, CodingKey {
        case pizzaId = "pizza_id"
        case ingredients
    }
}

struct OrderIngredientRequest: Encodable {
    let ingredientId: Int
    let isAdded: Bool
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case ingredientId = "ingredient_id"
        case isAdded = "is_added"
        case count
    }
}
