//
//  PaymentMethodsView.swift
//  PizzaFlow
//
//  Created by 596 on 06.04.2025.
//

import SwiftUI

struct PaymentMethodsView: View {
    @EnvironmentObject var apiClient: ApiClient
    @Environment(\.dismiss) var dismiss
    
    private let accentColor = Color("Orange")
    private let backgroundColor = Color("Dark")
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Способ оплаты")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Вариант 1: Оплата наличными
                PaymentOptionView(
                    title: "Наличными при получении",
                    icon: "banknote",
                    isSelected: apiClient.paymentMethod == .cash,
                    action: {
                        apiClient.paymentMethod = .cash
                        dismiss()
                    }
                )
                
                // Вариант 2: Оплата картой
                PaymentOptionView(
                    title: "Картой при получении",
                    icon: "creditcard",
                    isSelected: apiClient.paymentMethod == .card,
                    action: {
                        apiClient.paymentMethod = .card
                        dismiss()
                    }
                )
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Назад")
                    }
                    .foregroundColor(accentColor)
                }
            }
        }
    }
}

struct PaymentOptionView: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(Color("Orange"))
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color("Orange"))
                }
            }
            
            .padding()
            .background(Color("Dark"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color("Orange") : Color.white.opacity(0.2),
                    lineWidth: 1)
            )
        }
    }
}

// В ApiClient добавьте:
enum PaymentMethod: String, Codable {
    case cash, card
}

extension ApiClient {
    var paymentMethod: PaymentMethod {
        get {
            // Получаем из UserDefaults или другого хранилища
            UserDefaults.standard.string(forKey: "paymentMethod")
                .flatMap { PaymentMethod(rawValue: $0) } ?? .cash
        }
        set {
            // Сохраняем в UserDefaults или другое хранилище
            UserDefaults.standard.set(newValue.rawValue, forKey: "paymentMethod")
            objectWillChange.send()
        }
    }
}
