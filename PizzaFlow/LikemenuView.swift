//
//  LikemenuView.swift
//  PizzaFlow
//
//  Created by 596 on 03.03.2025.
//

import SwiftUI

struct LikemenuView: View {
    @EnvironmentObject var apiClient: ApiClient
    @Binding var selectedTab: Tab
    var body: some View {
        ZStack{
            Color("Dark").ignoresSafeArea(.all)
            VStack {
                Text("Избранные пиццы")
                    .font(.title)
                    .foregroundColor(Color("Orange"))
                    .padding(.top, 20)
                if apiClient.favoritePizzas.isEmpty {
                    Text("Вы еще не добавили пиццы в избранное 🍕")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                } else {
                    ScrollView{
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(apiClient.favoritePizzas) { pizza in
                                FavoritePizzaCardView(pizza: pizza)
                            }
                        }
                    }
                }
            }
            .onAppear{
                apiClient.fetchFavoritePizzas { success, error in
                    if success {
                        print("✅ Избранные пиццы загружены")
                    } else {
                        print("❌ Ошибка загрузки избранных пицц: \(error ?? "Неизвестная ошибка")")
                    }
                }
            }
        }
    }
}

#Preview {
    LikemenuView(selectedTab: .constant(.favourites))
}
