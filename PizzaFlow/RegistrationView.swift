//
//  RegistrationView.swift
//  PizzaFlow
//
//  Created by 596 on 02.03.2025.
//

import SwiftUI

struct RegistrationView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @EnvironmentObject var apiClient: ApiClient
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack{
            Color("Dark").ignoresSafeArea(.all)
            VStack{
                Text("Регистрация")
                    .foregroundColor(Color("Orange"))
                    .font(.system(size: 38, weight: .light))
                    .padding(.top, 40)
                Spacer(minLength: 5)
                VStack(spacing: 16){
                    CustomTextField(placeholder: "Введите имя пользователя", text: $username, isSecure: false)
                    CustomTextField(placeholder: "Введите почту", text: $email, isSecure: false)
                    PasswordField(placeholder: "Введите пароль", text: $password, isPasswordVisible: .constant(false))
                    PasswordField(placeholder: "Повторите пароль", text: $confirmPassword, isPasswordVisible: .constant(false))
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        if password == confirmPassword {
                            apiClient.register(username: username, email: email, password: password) { success, error in
                                if success {
                                    presentationMode.wrappedValue.dismiss()
                                } else {
                                    self.errorMessage = error
                                }
                            }
                        } else {
                            self.errorMessage = "Пароли не совпадают"
                        }
                    }){
                        Text("Зарегистрироваться")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(.white)
                            .frame(width: 215, height: 50)
                            .background(Color("Orange"))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .padding()
                }
                .padding(.horizontal, 16)
                
                Spacer(minLength: 20)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack{
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("Orange"))
                        Text("Назад")
                            .foregroundColor(Color("Orange"))
                    }
                }
            }
        }
    }
}


#Preview {
    RegistrationView()
}
