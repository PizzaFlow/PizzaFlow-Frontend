//
//  ContentView.swift
//  PizzaFlow
//
//  Created by 596 on 01.03.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        VStack(spacing: 0) { // Добавляем `spacing: 0`, чтобы не было зазора
            ZStack {
                switch selectedTab {
                case .favourites:
                    LikemenuView(selectedTab: $selectedTab)
                case .home:
                    MainMenuView(selectedTab: $selectedTab)
                case .map:
                    MapScreen(selectedTab: $selectedTab)
                case .cart:
                    CartMenuView(selectedTab: $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Расширяем контент на весь экран
                   
            CustomBar(selectedTab: $selectedTab) // Теперь `CustomBar` всегда внизу
                .frame(height: 70) // Фиксируем высоту панели
                .background(Color("Dark")) // Цвет фона панели
        }
        .ignoresSafeArea(.keyboard, edges: .bottom) // Убираем проблемы с клавиатурой
    }
}

#Preview {
    ContentView()
}
