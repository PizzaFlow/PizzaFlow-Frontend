//
//  IngridientView.swift
//  PizzaFlow
//
//  Created by 596 on 06.03.2025.
//

import SwiftUI

struct IngridientView: View {
    @EnvironmentObject var apiClient: ApiClient
    @State var pizza: Pizza
    @State private var isAddingIngredient = false
    @State private var selectedIngredients: [Ingredient]
    init(pizza: Pizza, selectedIngredients: [Ingredient]) {
        self.pizza = pizza
        _selectedIngredients = State(initialValue: selectedIngredients)
    }
    var body: some View {
        VStack {
            Text("Ингридиент пиццы \(pizza.name)")
                .font(.title2)
                .foregroundColor(Color("Orange"))
                .padding(.top, 20)
            List {
                ForEach(selectedIngredients) { ingredient in
                    IngredientRow(ingredient: ingredient,
                                  isSelected: true,
                                  onToggle: { removeIngredient(ingredient) }) }
            }
        }
        .background(Color.white)
            
        Text("Итоговая цена: \(String(format: "%.0f", calculateTotalPrice())) ₽")
            
        Button(action: {
            isAddingIngredient.toggle()
            apiClient.fetchPizzas()
        }) {
            Text("Добавить ингредиент")
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("Orange"))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
        }
        .padding(.bottom, 10)
        .sheet(isPresented: $isAddingIngredient) {
            AllIngredientsView(selectedIngredients: $selectedIngredients)
                .environmentObject(apiClient)
        }
    }
    private func removeIngredient(_ ingredient: Ingredient) {
        if let index = selectedIngredients.firstIndex(where: {$0.id == ingredient.id}){
            selectedIngredients.remove(at: index)
        }
    }
    private func calculateTotalPrice() -> Double {
        let price = pizza.price
        let extraIngredientsPrice = selectedIngredients
            .filter { ingredient in !pizza.ingredients.contains(where: { $0.id == ingredient.id }) } 
            .reduce(0) { $0 + $1.price }
        return price + extraIngredientsPrice
    }
}



