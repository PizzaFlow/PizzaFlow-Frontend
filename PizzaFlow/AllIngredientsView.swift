//
//  AllIngregientsView.swift
//  PizzaFlow
//
//  Created by 596 on 06.03.2025.
//

import SwiftUI

struct AllIngredientsView: View {
    @EnvironmentObject var apiClient: ApiClient
    @Binding var selectedIngredients: [Ingredient]
    let pizza: Pizza

    var body: some View {
            VStack{
                Text("Добавить ингредиенты")
                    .font(.title2)
                    .foregroundColor(Color("Orange"))
                    .padding(.top, 20)
                
                Spacer()
                
                Text("\(calculateTotalPrice(), specifier: "%.0f") ₽")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("Orange"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 20)
                List(apiClient.ingridients) { ingredient in
                    IngredientRow(ingredient: ingredient,
                                  isSelected: selectedIngredients.contains(where: { $0.id == ingredient.id}),
                                  onToggle: { toggleIngredient(ingredient) })
                }
         }
         .onAppear {
             apiClient.fetchAllIngredients()
         }
    }
    private func calculateTotalPrice() -> Double {
        let price = pizza.price
        let extraIngredientsPrice = selectedIngredients
            .filter { ingredient in !pizza.ingredients.contains(where: { $0.id == ingredient.id }) }
            .reduce(0) { $0 + $1.price }
        return price + extraIngredientsPrice
    }
    private func addIngredients( _ ingredient: Ingredient) {
        if !selectedIngredients.contains(where: { $0.id == ingredient.id }){
            selectedIngredients.append(ingredient)
        }
    }
    private func toggleIngredient(_ ingredient: Ingredient) {
            if let index = selectedIngredients.firstIndex(where: { $0.id == ingredient.id }) {
                selectedIngredients.remove(at: index)
            } else {
                selectedIngredients.append(ingredient)
            }
        }
}

