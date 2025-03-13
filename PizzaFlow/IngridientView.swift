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
    @State private var cart: [Pizza] = []
    @State private var selectedIngredients: [Ingredient]
    @EnvironmentObject var cartManager: CartManager
    @State private var isAddedToCart: Bool = false
    @State private var quantity: Int = 1
    
    init(pizza: Pizza, selectedIngredients: [Ingredient]) {
        self.pizza = pizza
        _selectedIngredients = State(initialValue: selectedIngredients)
    }

    var body: some View {
        VStack {
            HStack {
                Text(pizza.name)
                    .font(.title2)
                    .foregroundColor(Color("Orange"))
                    .padding(.top, 20)
                Spacer()
                Text("\(String(format: "%.0f", calculateTotalPrice())) ₽")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Dark"))
                    .padding(.leading, -10)
            }
            .padding(.top, 16)

            Button(action: {
                isAddingIngredient.toggle()
                apiClient.fetchPizzas()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color("Orange"))
                    Text("Добавить ингредиент")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("Orange"))
                }
            }
            .padding(8)
            .sheet(isPresented: $isAddingIngredient) {
                AllIngredientsView(selectedIngredients: $selectedIngredients)
                    .environmentObject(apiClient)
            }

            List {
                ForEach(selectedIngredients) { ingredient in
                    IngredientRow(ingredient: ingredient,
                                  isSelected: true,
                                  onToggle: { removeIngredient(ingredient) })
                }
            }
            .background(Color.white)

            Spacer()

            HStack(spacing: 10) {
                Button(action: {
                    //
                }) {
                    Text("Купить")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .padding()
                        .background(Color("Greenn"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                }

                if isAddedToCart {
                    HStack {
                        Button(action: {
                            if quantity > 1{
                                quantity -= 1
                                if let cartItem = cartManager.cartItems.first(where: { $0.pizza.id == pizza.id }) {
                                    cartManager.updateQuantity(for: cartItem, quantity: quantity)
                                }
                            }
                        }) {
                            Image(systemName: "minus")
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .padding(10)
                        }

                        Text("\(quantity)")
                            .font(.system(size: 18, weight: .bold))
                            .frame(width: 25)
                            .foregroundColor(.white)

                        Button(action: {
                            quantity += 1
                            if let cartItem = cartManager.cartItems.first(where: { $0.pizza.id == pizza.id }) {
                                cartManager.updateQuantity(for: cartItem, quantity: quantity)
                            }
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .padding(10)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 30)
                    .background(Color("Orange"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Button(action: {
                        cartManager.addToCart(pizza, ingredients: selectedIngredients)
                        isAddedToCart = true
                    }) {
                        Text("В корзину")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity, minHeight: 30)
                            .padding()
                            .background(Color("Orange"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isAddedToCart)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }

    private func removeIngredient(_ ingredient: Ingredient) {
        if let index = selectedIngredients.firstIndex(where: { $0.id == ingredient.id }) {
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
