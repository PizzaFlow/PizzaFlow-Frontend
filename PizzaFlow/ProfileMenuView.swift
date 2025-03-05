//
//  ProfileMenuVIew.swift
//  PizzaFlow
//
//  Created by 596 on 05.03.2025.
//

import SwiftUI

struct ProfileMenuView: View {
    @State private var isLoginPresented = false
    @State private var isRegistrationPresented = false
    @Binding var selectedTab: Tab
    @EnvironmentObject var apiClient: ApiClient
    var body: some View {
        Color("Dark").ignoresSafeArea(.all)
        VStack(spacing: 20) {
            if apiClient.token == nil {
                Text("Вы не вошли в аккаунт,")
                    .font(.system(size: 28, weight: .light, design: .default))
                    .foregroundColor(.white)
                // Spacer()
                Button(action:{
                    isLoginPresented.toggle()
                }){
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
                Button(action:{
                    isRegistrationPresented.toggle()
                }){
                    Text("Зарегистрируйтесь")
                        .font(.title)
                        .foregroundColor(Color("Orange"))
                    
                }
                .fullScreenCover(isPresented: $isRegistrationPresented){
                    RegistrationView()
                        .environmentObject(apiClient)
                }
                Text("чтобы управлять заказами!")
                    .font(.title3)
                    .foregroundColor(.white)
                
                Text("🍕")
                    .font(.system(size: 40))
            } else {
                Text("Вы вошли")
                
                Button(action:{
                    apiClient.logout()
                }){
                    HStack{
                        Image(systemName: "door.right.hand.open")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("Выйти из аккаунта")
                    }
                    .foregroundColor(.red)
                }
            }
        }
                    
    }
}


#Preview {
    ProfileMenuView(selectedTab: .constant(.profile))
}
