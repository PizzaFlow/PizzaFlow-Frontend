//
//  NotLoggedInView.swift
//  PizzaFlow
//
//  Created by 596 on 02.04.2025.
//

import SwiftUI

struct NotLoggedInView: View {
    @Binding var isLoginPresented: Bool
    @Binding var isRegistrationPresented: Bool
    @EnvironmentObject var apiClient: ApiClient
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Вы не вошли в аккаунт,")
                .font(.system(size: 28, weight: .light, design: .default))
                .foregroundColor(.white)
            
            Button(action: {
                isLoginPresented.toggle()
            }) {
                Text("Войдите")
                    .font(.title)
                    .foregroundColor(Color("Orange"))
            }
            .fullScreenCover(isPresented: $isLoginPresented) {
                LoginView()
                    .environmentObject(apiClient)
            }
            
            Text("или")
                .font(.title3)
                .foregroundColor(.white)
            
            Button(action: {
                isRegistrationPresented.toggle()
            }) {
                Text("Зарегистрируйтесь")
                    .font(.title)
                    .foregroundColor(Color("Orange"))
            }
            .fullScreenCover(isPresented: $isRegistrationPresented) {
                RegistrationView()
                    .environmentObject(apiClient)
            }
            
            Text("чтобы управлять заказами!")
                .font(.title3)
                .foregroundColor(.white)
            
            Text("🍕")
                .font(.system(size: 40))
        }
    }
}

