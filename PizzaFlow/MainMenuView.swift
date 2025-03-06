//
//  MainMenuView.swift
//  PizzaFlow
//
//  Created by 596 on 02.03.2025.
//

import SwiftUI

struct MainMenuView: View {
    @Binding var selectedTab: Tab
    @StateObject var apiClient = ApiClient()
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
                            Text("Волокамское шоссе, 4")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .medium))
                            Button(action:{
                                //
                            }){
                                Image(systemName: "chevron.down")
                                    .foregroundColor(Color("Orange"))
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    ScrollView {
                        LazyVGrid(columns: calumns, spacing: 20) {
                            ForEach(apiClient.pizzas) {pizza in
                                PizzaCardView(pizza: pizza)
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
            apiClient.fetchPizzas()
        }
    }
}
struct PizzaCardView: View {
    let pizza: Pizza
    @State private var isFavorite: Bool = false
    @State private var isIngridientPresented = false
    @State private var selectedIngredients: [Ingredient] = []
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
                    Button(action:{ isFavorite.toggle() }){
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
