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
        VStack(spacing: 0) {
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
                case .profile:
                    ProfileMenuView(selectedTab: $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
                   
            CustomBar(selectedTab: $selectedTab)
                .frame(height: 70)
                .background(Color("Dark"))
        }
        .ignoresSafeArea(.keyboard, edges: .bottom) 
    }
}

#Preview {
    ContentView()
}
