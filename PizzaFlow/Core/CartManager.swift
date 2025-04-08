//
//  CartManager.swift
//  PizzaFlow
//
//  Created by 596 on 09.03.2025.
//

import SwiftUI

class CartManager: ObservableObject {
    @Published var cartItems: [CartItem] = []
    var totalPrice: Int {
        cartItems.reduce(0) { $0 + Int($1.finalPrice) }
    }

    func addToCart(_ pizza: Pizza, ingredients: [Ingredient]) {
        if let index = cartItems.firstIndex(where: {
            $0.pizza.id == pizza.id &&
            $0.selectedIngredients.map(\.id).sorted() == ingredients.map(\.id).sorted()
        }) {
            updateQuantity(for: cartItems[index], quantity: cartItems[index].quantity + 1)
        } else {
            let newItem = CartItem(pizza: pizza, selectedIngredients: ingredients, quantity: 1)
            cartItems.append(newItem)
            cartItems = cartItems.map { $0 }
        }
    }

    func removeFromCart(_ cartItem: CartItem) {
        cartItems.removeAll { $0.id == cartItem.id }
        cartItems = cartItems.map { $0 } 
    }

    func updateQuantity(for cartItem: CartItem, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == cartItem.id }) {
            cartItems[index].quantity = quantity
            cartItems = cartItems.map { $0 }
            
            print("🟢 updateQuantity: \(cartItems[index].quantity)")
        }
    }
    func clearCart() {
        cartItems.removeAll()
        objectWillChange.send() 
    }
}
