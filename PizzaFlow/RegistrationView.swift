//
//  RegistrationView.swift
//  PizzaFlow
//
//  Created by 596 on 02.03.2025.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible : Bool = false
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
                    CustomTextField(placeholder: "Введите почту", text: $email, isSecure: false)
                    PasswordField(placeholder: "Введите пароль", text: $password, isPasswordVisible: $isPasswordVisible)
                    PasswordField(placeholder: "Повторите пароль", text: $password, isPasswordVisible: $isPasswordVisible)
                    
                    Button(action: {
                        //
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
