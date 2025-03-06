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

    var body: some View {
            VStack{
                Text("Добавить ингредиенты")
                    .font(.title2)
                    .foregroundColor(Color("Orange"))
                    .padding(.top, 20)
                List(apiClient.ingridients) { ingredient in
                    IngredientRow(ingredient: ingredient,
                                  isSelected: selectedIngredients.contains(where: { $0.id == ingredient.id}),
                                  onToggle: { toggleIngredient(ingredient) })
                }
                
//                if selectedIngredients.contains(where: { $0.id == ingredient.id }){
//                    Image(systemName: "checkmark.circle.fill")
//                        .foregroundColor(.green)
//                } else {
//                    Button(action: {
//                        addIngredients(ingredient)
//                    }) {
//                        Text("+")
//                            .foregroundColor(Color("Orange"))
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 8)
//                    }
//                }
        }
        .onAppear {
            apiClient.fetchAllIngredients()
        }
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

#Preview {
    AllIngredientsView(selectedIngredients: .constant([]))
}
