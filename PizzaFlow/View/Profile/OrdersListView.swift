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
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    if apiClient.orders.isEmpty {
                        Text("Нет заказов")
                            .font(.title2)
                            .foregroundColor(.gray)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(apiClient.orders) { order in
                                    OrdersCardView(order: order)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Мои заказы")
                        .font(.title)
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
            .foregroundColor(.white)
            .onAppear {
                Task {
                    do {
                        try await apiClient.fetchOrders()
                    } catch {
                        print("Ошибка загрузки заказов: \(error)")
                    }
                }
            }
        }
    }
}



struct OrdersCardView: View {
    let order: OrderResponse
    private let accentColor = Color("Orange")
    private let backgroundColor = Color("Dark")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Заказ №\(order.id)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(order.status)
                    .font(.system(size: 14))
                    .padding(6)
                    .background(statusColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            // Адрес доставки
            Text("\(order.address.city), \(order.address.street), \(order.address.house), кв. \(order.address.apartment)")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineLimit(1)
            
            // Список пицц
            VStack(alignment: .leading, spacing: 4) {
                ForEach(order.pizzas) { pizza in
                    HStack {
                        Text(pizza.pizza.name)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(Int(pizza.customPrice)) ₽")
                            .font(.system(size: 14))
                            .foregroundColor(accentColor)
                    }
                }
            }
            
            HStack {
                Text("Доставка: \(order.deliveryTime)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("Итого: \(Int(order.price)) ₽")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(backgroundColor.opacity(0.9))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(accentColor, lineWidth: 1)
        )
    }
 
    private var statusColor: Color {
        switch order.status.lowercased() {
        case "создан":
            return .orange
        case "в пути":
            return .blue
        case "доставлен":
            return .green
        default:
            return .gray
        }
    }
}

