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
    @State private var isLoading = false
    @State private var isPasswordVisible = false
    @FocusState private var focusedField: Field?
    
    @EnvironmentObject var apiClient: ApiClient
    @Environment(\.presentationMode) var presentationMode
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Dark")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer().frame(height: 40)
                        
                        Text("Вход")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                     
                        VStack(spacing: 20) {
                            // Поле email
                            CustomTextField(
                                placeholder: "Введите почту",
                                text: $email,
                                icon: "envelope",
                                keyboardType: .emailAddress
                            )
                            .focused($focusedField, equals: .email)
                            
                            PasswordFieldWithToggle(
                                placeholder: "Введите пароль",
                                text: $password,
                                isPasswordVisible: $isPasswordVisible
                            )
                            .focused($focusedField, equals: .password)
                            
                            if let errorMessage = errorMessage {
                                ErrorMessageView(text: errorMessage)
                            }
                            
                            LoginButton {
                                attemptLogin()
                            }
                            .disabled(isLoading)
                            
                            HStack{
                                Text("Нету аккаунта?")
                                    .foregroundColor(.white)
                                NavigationLink(destination: RegistrationView()){
                                    Text("Зарегестрируйтесь")
                                        .foregroundColor(Color("Orange"))
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer()
                    }
                    .padding(.bottom, 30)
                    .frame(minHeight: UIScreen.main.bounds.height)
                }
                .scrollDismissesKeyboard(.interactively)
                
                if isLoading {
                    LoadingOverlay()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func attemptLogin() {
        isLoading = true
        errorMessage = nil
        
        apiClient.login(email: email, password: password) { success, error in
            isLoading = false
            if success {
                presentationMode.wrappedValue.dismiss()
            } else {
                errorMessage = error ?? "Неизвестная ошибка"
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}
// MARK: - Компоненты

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String?
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(Color("Orange"))
                    .frame(width: 20)
            }
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textContentType(.none)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .foregroundColor(.black)
                .tint(Color("Orange"))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


struct ErrorMessageView: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
            Text(text)
        }
        .foregroundColor(.red)
        .font(.caption)
        .transition(.opacity)
    }
}



struct LoginButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Войти")
                .font(.headline)
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



struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
    }
}

// MARK: - Стили и модификаторы

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}


struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .offset(y: -keyboardHeight / 2) 
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        let keyboardHeightInWindow = keyboardFrame.height
                        let safeAreaBottom = geometry.safeAreaInsets.bottom
                        self.keyboardHeight = keyboardHeightInWindow - safeAreaBottom
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    self.keyboardHeight = 0
                }
                .animation(.easeInOut(duration: 0.25), value: keyboardHeight)
        }
    }
}
