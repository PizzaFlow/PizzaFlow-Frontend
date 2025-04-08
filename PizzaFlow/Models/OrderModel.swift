//
//  OrderModel.swift
//  PizzaFlow
//
//  Created by 596 on 05.04.2025.
//


struct OrderResponse: Decodable, Identifiable {
    let id: Int
    let user: User
    let address: Address
    let status: String
    let price: Double
    let createdAt: String
    let deliveryTime: String
    let pizzas: [OrderPizzaResponse]
    let paymentMethod: String
    
    enum CodingKeys: String, CodingKey {
        case id, user, address, status, price
        case createdAt = "created_at"
        case deliveryTime = "delivery_time"
        case pizzas
        case paymentMethod = "payment_method"
    }
}

struct OrderPizzaResponse: Decodable, Identifiable {
    let id: Int
    let pizza: Pizza
    let customPrice: Double
    let ingredients: [OrderIngredientResponse]
    
    enum CodingKeys: String, CodingKey {
        case id, pizza
        case customPrice = "custom_price"
        case ingredients
    }
}

struct OrderIngredientResponse: Decodable {
    let ingredientId: Int
    let isAdded: Bool
    let count: Int
    let ingredient: Ingredient
    
    enum CodingKeys: String, CodingKey {
        case ingredientId = "ingredient_id"
        case isAdded = "is_added"
        case count, ingredient
    }
}
