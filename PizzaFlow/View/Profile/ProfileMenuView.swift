//
//  ProfileMenuView.swift
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
    @State private var isEditProfilePresented = false
    
    var body: some View {
        Color("Dark").ignoresSafeArea(.all)
        VStack {
            if apiClient.token == nil {
                NotLoggedInView(isLoginPresented: $isLoginPresented, isRegistrationPresented: $isRegistrationPresented)
            } else {
                LoggedInView(isEditProfilePresented: $isEditProfilePresented, selectedTab: $selectedTab)
            }
        }
        .onAppear {
            Task {
                if apiClient.token != nil {
                    if await apiClient.currentUser == nil {
                        apiClient.fetchCurrentUser { result in
                            switch result {
                            case .success(let user):
                                print("User: \(user)")
                            case .failure(let error):
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }
    }
    
}

struct NavigationOptionRow<Destination: View>: View {
    let title: String
    let icon: String
    let destination: () -> Destination
    
    init(title: String, icon: String, @ViewBuilder destination: @escaping () -> Destination) {
        self.title = title
        self.icon = icon
        self.destination = destination
    }
    
    var body: some View {
        NavigationLink(destination: destination()) {
            OptionRowContent(title: title, icon: icon)
        }
    }
}

struct ActionOptionRow: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            OptionRowContent(title: title, icon: icon)
        }
    }
}

struct OptionRowContent: View {
    let title: String
    let icon: String
    
    var body: some View {
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
            
            Image(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundColor(Color("Orange"))
        }
        .padding()
        .background(Color("Dark"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
#Preview {
    ProfileMenuView(selectedTab: .constant(.profile))
}
