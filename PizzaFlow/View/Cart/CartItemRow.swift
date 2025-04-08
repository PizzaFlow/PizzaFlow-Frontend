//
//  CartItemRow.swift
//  PizzaFlow
//
//  Created by 596 on 07.04.2025.
//

import SwiftUI

struct CartItemRow: View {
    @EnvironmentObject var cartManager: CartManager
    let item: CartItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                if let imageUrl = URL(string: item.pizza.photo) {
                    AsyncImage(url: imageUrl) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.pizza.name)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Spacer()
                        
                        Text("\(Int(item.finalPrice)) ₽")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    
                    if let ingredients = item.pizza.ingredients, !ingredients.isEmpty {
                        Text("Состав: \(ingredients.map { $0.name }.joined(separator: ", "))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
              
                    if !item.selectedIngredients.isEmpty {
                        let extras = item.selectedIngredients
                            .filter { ing in !(item.pizza.ingredients?.contains { $0.id == ing.id } ?? false) }
                        
                        if !extras.isEmpty {
                            Text("Добавки: \(extras.map { "+\($0.name)" }.joined(separator: ", "))")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                        }
                    }
                  
                    HStack {
                        Button {
                            cartManager.updateQuantity(for: item, quantity: max(1, item.quantity - 1))
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.orange)
                        }
                        
                        Text("\(item.quantity)")
                            .frame(minWidth: 20)
                        
                        Button {
                            cartManager.updateQuantity(for: item, quantity: item.quantity + 1)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.orange)
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                cartManager.removeFromCart(item)
                            }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .font(.system(size: 14))
                    .padding(.top, 4)
                }
            }
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                withAnimation {
                    cartManager.removeFromCart(item)
                }
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
}
