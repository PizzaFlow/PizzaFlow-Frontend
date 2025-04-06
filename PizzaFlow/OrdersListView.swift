//
//  OrdersListView.swift
//  PizzaFlow
//
//  Created by 596 on 06.04.2025.
//

import SwiftUI

struct OrdersListView: View {
    @ObservedObject var apiClient: ApiClient
    private let accentColor = Color("Orange")
    private let backgroundColor = Color("Dark")
    var body: some View {
        NavigationStack{
            ZStack{
                backgroundColor.ignoresSafeArea()
                Text("Список Заказов")
                    .foregroundColor(.white)
            }
        }
    }
}

