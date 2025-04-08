//
//  RegistrationView.swift
//  PizzaFlow
//
//  Created by 596 on 02.03.2025.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @FocusState private var focusedField: Field?
    
    @EnvironmentObject var apiClient: ApiClient
    @Environment(\.dismiss) var dismiss
    
    enum Field {
        case email, password, confirmPassword
    }
    
    var body: some View {
        ZStack {
            Color("Dark")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                RegistrationHeader()

                ScrollView {
                    VStack(spacing: 20) {
                        CustomTextField(
                            placeholder: "Электронная почта",
                            text: $email,
                            icon: "envelope"
                        )
                        .focused($focusedField, equals: .email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        
                        PasswordFieldWithToggle(
                            placeholder: "Пароль",
                            text: $password,
                            isPasswordVisible: $isPasswordVisible
                        )
                        .focused($focusedField, equals: .password)
                        .textContentType(.newPassword)
                        .onSubmit { focusedField = .confirmPassword }

                        PasswordFieldWithToggle(
                            placeholder: "Подтвердите пароль",
                            text: $confirmPassword,
                            isPasswordVisible: $isConfirmPasswordVisible
                        )
                        .focused($focusedField, equals: .confirmPassword)
                        .textContentType(.newPassword)
                        .onSubmit { attemptRegistration() }
                        
                        if let errorMessage = errorMessage {
                            ErrorMessageView(text: errorMessage)
                        }
                        
                        RegistrationButton {
                            attemptRegistration()
                        }
                        .disabled(isLoading)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()

                    LoginLink()
                }
                .padding(.vertical, 30)
            }
            .keyboardAdaptive()
            
            
            if isLoading {
                LoadingOverlay()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    dismiss()
                }
            }
        }
    }
    
    private func attemptRegistration() {
        guard !isLoading else { return }

        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Все поля обязательны для заполнения"
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Пароли не совпадают"
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        guard password.count >= 5 else {
            errorMessage = "Пароль должен содержать минимум 5 символов"
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        apiClient.register(email: email, password: password) { success, error in
            isLoading = false
            
            if success {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                dismiss()
            } else {
                errorMessage = error ?? "Ошибка регистрации"
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}

// MARK: - Компоненты

struct RegistrationHeader: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Создайте аккаунт")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Заполните форму для регистрации")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct PasswordFieldWithToggle: View {
    var placeholder: String
    @Binding var text: String
    @Binding var isPasswordVisible: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(Color("Orange"))
                .frame(width: 20)
            
            if isPasswordVisible {
                TextField(placeholder, text: $text)
                    .textContentType(.none)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(.black)
                    .tint(Color("Orange"))
            } else {
                SecureField(placeholder, text: $text)
                    .textContentType(.none) 
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(.black)
                    .tint(Color("Orange"))
            }
            
            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    .foregroundColor(Color("Orange"))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct RegistrationButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("Зарегистрироваться")
                    .font(.headline)
                
                Image(systemName: "arrow.right")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("Orange"))
            .cornerRadius(10)
            .shadow(color: Color("Orange").opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct LoginLink: View {
    var body: some View {
        HStack {
            Text("Уже есть аккаунт?")
                .foregroundColor(.white)
            
            NavigationLink(destination: LoginView()) {
                Text("Войти")
                    .foregroundColor(Color("Orange"))
                    .fontWeight(.semibold)
            }
        }
        .font(.callout)
    }
}

struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                Text("Назад")
            }
            .foregroundColor(Color("Orange"))
        }
    }
}


