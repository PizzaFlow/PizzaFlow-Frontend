//
//  Registration.swift
//  PizzaFlow
//
//  Created by 596 on 01.03.2025.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @EnvironmentObject var apiClient: ApiClient
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Dark")
                    .ignoresSafeArea(.all)
                ScrollView {
                    VStack{
                        Spacer(minLength: 60)
                        Text("Вход")
                            .font(.system(size: 28, weight: .light, design: .default))
                            .foregroundColor(Color("White"))
                        VStack (spacing: 20){
                            CustomTextField(placeholder: "Введите почту", text: $email, isSecure: false)
                            PasswordField(placeholder: "Введите пароль", text: $password, isPasswordVisible: .constant(false))
                            
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                            Button (action: {
                                //
                            }){
                                Text("Забыли пароль?")
                                    .foregroundColor(Color("Orange"))
                                    .padding(.trailing, 190)
                            }
                            Button (action: {
                                apiClient.login(email: email, password: password) { success, error in
                                    if success {
                                        presentationMode.wrappedValue.dismiss()
                                    } else{
                                        self.errorMessage = error
                                    }
                                }
                            }){
                                Text("Войти")
                                    .font(.system(size: 22, weight: .light, design: .default))
                                    .frame(width: 104, height: 20)
                                    .padding()
                                    .background(Color("Orange"))
                                    .foregroundColor(Color("White"))
                                    .cornerRadius(15.0)
                            }
                            Spacer()
                            HStack{
                                Text("Нету аккаунта?")
                                    .font(.system(size: 20, weight: .light, design: .default))
                                    .foregroundColor(Color("White"))
                                NavigationLink(destination: RegistrationView()){
                                    Text("Зарегистрируйтесь!")
                                        .font(.system(size: 20, weight: .light, design: .default))
                                        .foregroundColor(Color("Orange"))
                                }
                            }
                            
                            HStack {
                                Text("Войти как")
                                    .font(.system(size: 20, weight: .light, design: .default))
                                    .foregroundColor(Color("White"))
                                Button(action: {
                                    //
                                }){
                                    Text("сотрудник")
                                        .font(.system(size: 20, weight: .light, design: .default))
                                        .foregroundColor(Color("Orange"))
                                    
                                }
                                
                            }
                        }
                    }
                    .ignoresSafeArea(.keyboard)
                }
                
            }
        }
    }
    
}
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                .background(Color.white)
                .cornerRadius(10)
                .frame(width: 308, height: 42)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding(.horizontal, 16)
                    .frame(width: 308, height: 42)
                    .foregroundColor(.black)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal, 16)
                    .frame(width: 308, height: 42)
            }
        }
    }
}

struct PasswordField: View {
    var placeholder: String
    @Binding var text: String
    @Binding var isPasswordVisible: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                .background(Color.white)
                .cornerRadius(10)
                .frame(width: 308, height: 42)
            HStack {
                if isPasswordVisible {
                    TextField(placeholder, text: $text)
                        .padding(.horizontal, 16)
                        .frame(width: 308, height: 42)
                } else {
                    SecureField(placeholder, text: $text)
                        .padding(.horizontal, 16)
                        .frame(height: 42)
                }
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slah.fill" : "eye.fill" )
                        .foregroundColor(Color("Orange"))
                        .padding(.trailing, 14)
                }
            }
            .frame(width: 308, height: 42)
        }
    }
}
    

#Preview {
    LoginView()
}
