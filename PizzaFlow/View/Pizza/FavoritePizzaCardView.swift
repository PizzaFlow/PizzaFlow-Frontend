//
//  FavoritePizzaCardView.swift
//  PizzaFlow
//
//  Created by 596 on 07.03.2025.
//

import SwiftUI

struct FavoritePizzaCardView: View {
    @EnvironmentObject var apiClient: ApiClient
    let pizza: Pizza
    @State private var isFavorite: Bool
    @State private var isIngridientPresented = false
    @Binding var selectedTab: Tab
    
    init(pizza: Pizza, selectedTab: Binding<Tab>) {
        self.pizza = pizza
        self._isFavorite = State(initialValue: true)
        _selectedTab = selectedTab
    }
    
    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: pizza.photo)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .scaledToFit()
            .frame(height: 130)
            .padding(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(pizza.price, specifier: "%.2f") ₽")
                    .foregroundColor(Color("Orange"))
                    .font(.system(size: 18, weight: .bold))
                    .padding(.leading)
                
                Text(pizza.name)
                    .foregroundColor(Color("Dark"))
                    .font(.system(size: 17, weight: .bold))
                    .padding(.leading)
                
                Spacer()
                
                HStack{
                    Button(action: {
                        isFavorite.toggle()
                        if !isFavorite {
                            apiClient.removePizzaFromFavorites(pizzaID: pizza.id) { success, message in
                                if success {
                                    print("✅ Пицца удалена из избранного")
                                    apiClient.fetchFavoritePizzas(completion: { _, _ in })
                                } else {
                                    print("❌ Ошибка: \(message ?? "Неизвестная ошибка")")
                                    isFavorite = true
                                }
                            }
                        }
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(isFavorite ? .red : Color("Dark"))
                            .padding(.leading, 8)
                    }

                    
                    Button(action: {
                        isIngridientPresented.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Добавить")
                                .font(.system(size: 15))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color("Orange"))
                        .cornerRadius(15)
                    }
                    .sheet(isPresented: $isIngridientPresented) {
                        IngridientView(pizza: pizza, selectedIngredients: pizza.ingredients ?? [], selectedTab: $selectedTab)
                    }
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            isFavorite = apiClient.favoritePizzas.contains(where: { $0.id == pizza.id })
        }
    }
}
