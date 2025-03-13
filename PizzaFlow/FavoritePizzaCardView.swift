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
    init(pizza: Pizza) {
        self.pizza = pizza
        self._isFavorite = State(initialValue: true)
    }
    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: pizza.photo)) {image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .scaledToFit()
            .frame(height: 130)
            .padding(8)
            
            VStack(alignment: .leading, spacing: 4){
                Text("\(pizza.price, specifier: "%.0f") ₽")
                    .foregroundColor(Color("Orange"))
                    .font(.system(size: 18, weight: .bold))
                    .padding(.leading)
                Spacer()
                Text(pizza.name)
                    .foregroundColor(Color("Dark"))
                    .font(.system(size: 17, weight: .bold))
                    .padding(.leading)
                Spacer()
                
                HStack {
                    Button(action: {
                        isFavorite.toggle()
                        if !isFavorite {
                            apiClient.removePizzaFromFavorites(pizzaID: pizza.id) { success, message in
                                if success {
                                    print("✅ Пицца удалена из избранного")
                                    apiClient.fetchFavoritePizzas(completion: { _,_ in })
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
                            .foregroundColor(isFavorite ? .red : .gray)
                            .padding(.leading)
                    }
                    
                    Spacer()
                    Button(action: {
                        //
                    }) {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("В корзину")
                                .font(.system(size: 15))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical,8)
                        .background(Color("Orange"))
                        .cornerRadius(15)
                    }
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        }
        .onAppear{
            isFavorite = apiClient.favoritePizzas.contains(where: { $0.id == pizza.id })
        }
    }
}
