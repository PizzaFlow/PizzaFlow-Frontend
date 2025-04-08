//
//  OrderSuccesView.swift
//  PizzaFlow
//
//  Created by 596 on 07.04.2025.
//

import SwiftUI

struct OrderSuccessView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var apiClient: ApiClient
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
            
            Text("Заказ №\(apiClient.currentOrder?.id ?? 0) оформлен!")
                .font(.title.bold())
            
            if let order = apiClient.currentOrder {
                Text("Доставка: \(order.deliveryTime)")
                Text("Сумма: \(Int(order.price)) ₽")
            }
            
            Button(action: {
                selectedTab = .home
            }) {
                Text("К пиццам!")
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("Orange"))
        }
        .padding()
    }
}
