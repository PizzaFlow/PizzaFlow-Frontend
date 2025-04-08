//
//  ChangePasswordView.swift
//  PizzaFlow
//
//  Created by 596 on 03.04.2025.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var apiClient: ApiClient
    
    @Binding var newPassword: String
    @State private var errorMessage: String?
    @State private var isUpdating = false
    @State private var showPassword = false
    @State private var showSuccessAlert = false
    @State private var isCurrentPasswordValid = false
    @State private var currentPasswordError: String?
    var onSave: () -> Void
    
    private let accentColor = Color("Orange")
    private let backgroundColor = Color("Dark")
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 40))
                            .foregroundColor(accentColor)
                            .padding(.bottom, 8)
                        
                        Text("Смена пароля")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text("Введите новый пароль")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 24)
                    
                    VStack(spacing: 16) {
                        passwordField("Новый пароль", text: $newPassword, icon: "lock.fill")
                            .onChange(of: newPassword) { _ in
                                print("Новый пароль: \(newPassword)")
                            }
                       
                    }
                    .padding(.horizontal)
                    Button(action: {
                        withAnimation {
                            showPassword.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(accentColor)
                            Text(showPassword ? "Скрыть пароли" : "Показать пароли")
                                .foregroundColor(.white)
                        }
                        .font(.subheadline)
                    }
                    .padding(.top, 8)
                    
                    if let error = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .foregroundColor(.red)
                        }
                        .transition(.opacity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        Task { await changePassword() }
                    }) {
                        if isUpdating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Сохранить изменения")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isFormValid ? accentColor : .gray.opacity(0.5))
                    .controlSize(.large)
                    .disabled(!isFormValid || isUpdating)
                    .animation(.default, value: isFormValid)
                    .padding(.top, 24)
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Закрыть") { dismiss() }
                    .foregroundColor(accentColor)
            }
        }
        .alert("Пароль изменён", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text("Ваш пароль был успешно изменён.")
        }
    }
    
    private func passwordField(_ title: String, text: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                Text(title)
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            
            if showPassword {
                TextField("", text: text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .tint(accentColor)
            } else {
                SecureField("", text: text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .tint(accentColor)
            }
            
            Divider()
                .background(Color.gray.opacity(0.5))
        }
    }
    
    private var isFormValid: Bool {
        let isValid = !newPassword.isEmpty && newPassword.count >= 5
        
        print("Проверка формы:")
        print("- Новый пароль: '\(newPassword)'")
        print("- Длина: \(newPassword.count) символов")
        print("- Форма валидна: \(isValid)")
        
        return isValid
    }
    
    
    
    private func changePassword() async {
        guard isFormValid else { return }
        
        isUpdating = true
        errorMessage = nil
        
        do {
            try await apiClient.changePassword(
                newPassword: newPassword
            )
            await MainActor.run {
                showSuccessAlert = true
                isUpdating = false
                newPassword = ""
            }
        } catch {
            await MainActor.run {
                errorMessage = "Ошибка: \(error.localizedDescription)"
                isUpdating = false
            }
        }
    }
}
