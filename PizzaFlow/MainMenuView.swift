//
//  MainMenuView.swift
//  PizzaFlow
//
//  Created by 596 on 02.03.2025.
//

import SwiftUI

struct MainMenuView: View {
    @Binding var selectedTab: Tab
    @ObservedObject var apiClient = ApiClient()
    @State private var showAddressSheet = false
    let calumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    var body: some View {
        return NavigationStack {
            ZStack {
                Color("Dark").ignoresSafeArea(.all)
                VStack {
                    HStack{
                        HStack(spacing: 4){
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(Color("Orange"))
                            
                            Button(action:{
                                showAddressSheet = true
                            }){
                                HStack {
                                    if let selectedAddress = apiClient.selectedAddress {
                                        Text("\(selectedAddress.city), \(selectedAddress.street), \(selectedAddress.house)")
                                            .foregroundColor(.white)
                                            .font(.system(size: 15, weight: .medium))
                                            .lineLimit(1)
                                    } else if apiClient.addresses.isEmpty {
                                        Text("Добавьте адрес")
                                            .foregroundColor(.white)
                                            .font(.system(size: 15, weight: .medium))
                                            .lineLimit(1)
                                    } else {
                                        Text("Выберите адрес")
                                            .foregroundColor(.white)
                                            .font(.system(size: 15, weight: .medium))
                                            .lineLimit(1)
                                    }
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(Color("Orange"))
                                }
                            }
                            .sheet(isPresented: $showAddressSheet) { 
                                AddressListSheet(apiClient: apiClient)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    ScrollView {
                        LazyVGrid(columns: calumns, spacing: 20) {
                            ForEach(apiClient.pizzas, id: \.id) { pizza in
                                PizzaCardView(pizza: pizza)
                                    .environmentObject(apiClient)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 50)
                    }
                    
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear{
            print("🔄 onAppear вызван")
            apiClient.fetchPizzas()
            apiClient.fetchFavoritePizzas{ success, errorMessage in
                if success {
                    print("✅ Избранные пиццы успешно загружены!")
                } else {
                    print("❌ Ошибка загрузки избранных пицц: \(errorMessage ?? "Неизвестная ошибка")")
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                print("🔄 Принудительное обновление UI")
            }
        }
    }
}

struct PizzaCardView: View {
    @EnvironmentObject var apiClient: ApiClient
    let pizza: Pizza
    @State private var isIngridientPresented = false
    @State private var selectedIngredients: [Ingredient] = []
    var isFavorite: Bool {
        apiClient.favoritePizzas.contains(where: { $0.id == pizza.id })
    }
    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: pizza.photo)) {image in
                image.resizable()
            } placeholder: {
                Image(systemName: "photo").resizable().scaledToFit().foregroundColor(.gray)
            }
            .scaledToFit()
            .frame(height: 130)
            .padding(8)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(pizza.price, specifier: "%.2f") ₽")
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
                    Button(action:{
                        if isFavorite {
                            apiClient.removePizzaFromFavorites(pizzaID: pizza.id) { success, message in
                                if success {
                                    print("✅ Пицца удалена из избранного")
                                    apiClient.fetchFavoritePizzas(completion: { _, _ in })
                                    apiClient.movePizzaToMainList(pizza: pizza)
                                } else {
                                    print("❌ Ошибка: \(message ?? "Неизвестная ошибка")")
                                }
                            }
                        } else {
                            apiClient.addPizzaToFavorites(pizzaID: pizza.id) { success, message in
                                if success {
                                    print("✅ Пицца добавлена в избранное")
                                    apiClient.movePizzaToTop(pizza: pizza)
                                    apiClient.fetchFavoritePizzas(completion: { _, _ in })
                                } else {
                                    print("❌ Ошибка: \(message ?? "Неизвестная ошибка")")
                                }
                            }
                        }
                    }){
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(isFavorite ? .red : Color("Dark"))
                            .padding(.leading, 8)
                    }
                    // Spacer()
                    
                    Button(action:{
                        isIngridientPresented.toggle()
                    }) {
                        HStack{
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
                    .sheet(isPresented: $isIngridientPresented){
                        IngridientView(pizza: pizza, selectedIngredients: pizza.ingredients)
                    }
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .padding([.leading, .trailing], 12)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct CustomBar: View {
    @Binding var selectedTab: Tab
    var body: some View {
        HStack {
            Spacer()
            TabBarButton(image: "heart", tab: .favourites, selectedTab: $selectedTab)
            Spacer()
            TabBarButton(image: "house.fill", tab: .home, selectedTab: $selectedTab)
            Spacer()
            TabBarButton(image: "map", tab: .map, selectedTab: $selectedTab)
            Spacer()
            TabBarButton(image: "cart", tab: .cart, selectedTab: $selectedTab)
            Spacer()
            TabBarButton(image: "person.crop.circle", tab: .profile, selectedTab: $selectedTab)
                .padding(.trailing, 10)
        }
        .frame(height: 70)
        .background(Color("Dark"))
        .offset(x: -10)
    }
}
struct TabBarButton: View {
    let image: String
    let tab: Tab
    @Binding var selectedTab: Tab
    var body: some View {
        Button(action:{
            selectedTab = tab
            print("Выбрана вкладка: \(selectedTab)")
        }){
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundColor(selectedTab == tab ? .white : Color("Orange"))
        }
    }
}

#Preview {
    MainMenuView(selectedTab: .constant(.home))
}
