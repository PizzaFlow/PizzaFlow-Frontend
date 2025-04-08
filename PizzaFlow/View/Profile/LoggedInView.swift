//
//  LoggedInView.swift
//  PizzaFlow
//
//  Created by 596 on 02.04.2025.
//

import SwiftUI

struct LoggedInView: View {
    @EnvironmentObject var apiClient: ApiClient
    @Binding var isEditProfilePresented: Bool
    @State private var showEditProfile = false
    @State private var displayedUsername: String = "Введите имя"
    @State private var displayedPhone: String = "Введите номер"
    @State private var displayedEmail: String = "Email не указан"
    @Binding var selectedTab: Tab

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Dark").ignoresSafeArea()
                    VStack(spacing: 20) {
                        Text("Профиль")
                            .font(.title)
                            .foregroundColor(Color("Orange"))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal)
                        
                        // Карточка профиля
                        ScrollView {
                            NavigationLink(destination: EditProfileView(onSave: {
                                self.loadUserData()
                            })
                            .environmentObject(apiClient)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(displayedUsername)
                                            .font(.title2)
                                            .foregroundColor(Color("Orange"))
                                        
                                        
                                        Spacer()
                                        
                                        Image(systemName: "gear")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(Color("Orange"))
                                    }
                                    
                                    Text(displayedPhone)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    
                                    Text(displayedEmail.isEmpty ? "Email не указан" : displayedEmail)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    
                                    
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .cornerRadius(15)
                    
                        }
                        .padding(.horizontal)
 
                            NavigationLink(destination: OrdersListView(apiClient: apiClient)) {
                            HStack {
                                Image(systemName: "basket")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color("Orange"))
                                
                                Text("Мои заказы")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color("Orange"))
                            }
                            .padding()
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .cornerRadius(15)
                        }
                        .padding(.horizontal)
                            
                            VStack(spacing: 16) {
                                NavigationOptionRow(title: "Способ оплаты", icon: "creditcard") {
                                    PaymentMethodsView()
                                }
                                
                                ActionOptionRow(title: "Любимые пиццы", icon: "heart") {
                                    selectedTab = .favourites
                                }
                                
                                NavigationOptionRow(title: "Адреса", icon: "mappin.circle") {
                                    AdressListView(apiClient: apiClient)
                                }
                            }
                        .padding(.top, 20)
                        .padding(.horizontal)
                        
                        
                        Spacer()
                    }
                    .padding(.top)
                }
                .navigationBarHidden(true)
            }
        }
        .tint(Color("Orange"))
        .onAppear {
            loadUserData() 
        }
    }
    
    private func loadUserData() {
        Task {
            if let user = await apiClient.currentUser {
                await updateDisplay(user: user)
            }
        }
    }
    @MainActor
    private func updateDisplay(user: User) {
        DispatchQueue.main.async {
            self.displayedUsername = user.username?.isEmpty ?? true ? "Введите имя" : user.username ?? ""
            self.displayedPhone = user.phone_number?.isEmpty ?? true ? "Введите номер" : formatPhoneNumber(user.phone_number ?? "")
            self.displayedEmail = user.email.isEmpty ? "Email не указан" : user.email
        }
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let cleanNumber = number.filter { $0.isNumber }
        guard !cleanNumber.isEmpty else { return "" }
        
        let mask = "+X (XXX) XXX-XX-XX"
        var result = ""
        var index = cleanNumber.startIndex
        
        for ch in mask {
            guard index < cleanNumber.endIndex else { break }
            
            if ch == "X" {
                result.append(cleanNumber[index])
                index = cleanNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        
        return result
    }
    
    private func updateUserDisplay() {
        Task {
            if let user = await apiClient.currentUser {
                updateDisplay(user: user)
            }
        }
    }
}
