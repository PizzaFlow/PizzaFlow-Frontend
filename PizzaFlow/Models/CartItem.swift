//
//  CartItem.swift
//  PizzaFlow
//
//  Created by 596 on 09.03.2025.
//

import Foundation

class CartItem: Identifiable {
    var id = UUID()
    let pizza: Pizza
    let selectedIngredients: [Ingredient]
    var quantity: Int

    var finalPrice: Double {
        let basePrice = pizza.price
        let extraIngredientsPrice = selectedIngredients
            .filter { ingredient in !(pizza.ingredients?.contains(where: { $0.id == ingredient.id }) ?? false) }
            .reduce(0) { $0 + $1.price }
        return (basePrice + extraIngredientsPrice) * Double(quantity)
    }

    init(id: UUID = UUID(), pizza: Pizza, selectedIngredients: [Ingredient], quantity: Int) {
        self.id = id
        self.pizza = pizza
        self.selectedIngredients = selectedIngredients
        self.quantity = quantity
    }
}
