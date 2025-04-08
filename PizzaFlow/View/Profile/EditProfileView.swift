//
//  EditProfileView.swift
//  PizzaFlow
//
//  Created by 596 on 02.04.2025.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var apiClient: ApiClient
    @Environment(\.dismiss) var dismiss
    @State private var showPasswordSheet = false
    @State private var username = ""
    @State private var phoneNumber = ""
    @State private var formattedPhoneNumber = ""
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var hasChanges = false
    @State private var showSuccessAlert = false
    var onSave: () -> Void
    
    // Цвета
    private let darkColor = Color("Dark")
    private let orangeColor = Color("Orange")
    
    var body: some View {
        ZStack {
            darkColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    profileForm
                    saveButton
                    logoutButton
                    
                    if let error = errorMessage {
                        errorMessageView(error)
                    }
                }
                .padding(.top)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showPasswordSheet) { passwordChangeSheet }
        .alert("Изменения сохранены", isPresented: $showSuccessAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("Ваши данные были успешно обновлены.")
        }
        .onAppear { loadUserData() }
        .onChange(of: username) { _ in checkForChanges() }
        .onChange(of: phoneNumber) { _ in
            formattedPhoneNumber = formatPhoneNumber(phoneNumber)
            checkForChanges()
        }
    }
    
    // MARK: - Subviews
    
    private var profileForm: some View {
        VStack(spacing: 16) {
            nameField
            phoneField
            changePasswordButton
        }
        .padding()
        .background(darkColor)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var nameField: some View {
        HStack {
            Text("Имя:")
                .foregroundColor(orangeColor)
                .frame(width: 80, alignment: .leading)
            
            TextField("Введите имя", text: $username)
                .textFieldStyle(ProfileFieldStyle())
        }
    }
    
    private var phoneField: some View {
        HStack {
            Text("Номер:")
                .foregroundColor(orangeColor)
                .frame(width: 80, alignment: .leading)
            
            TextField("+7 (000) 000-00-00", text: $formattedPhoneNumber)
                .keyboardType(.numberPad)
                .textFieldStyle(ProfileFieldStyle())
                .onChange(of: formattedPhoneNumber) { newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered.count <= 11 {
                        phoneNumber = "+7" + (filtered.count > 1 ? String(filtered.dropFirst()) : "")
                        formattedPhoneNumber = formatPhoneNumber(phoneNumber)
                    } else {
                        formattedPhoneNumber = formatPhoneNumber(phoneNumber)
                    }
                }
        }
    }
    
    private var changePasswordButton: some View {
        HStack {
            Text("Пароль:")
                .foregroundColor(orangeColor)
                .frame(width: 80, alignment: .leading)
            
            Button(action: { showPasswordSheet = true }) {
                HStack {
                    Text("Изменить пароль")
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var saveButton: some View {
        Button(action: saveChanges) {
            Text(isSaving ? "Сохранение..." : "Сохранить изменения")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
        }
        .buttonStyle(SaveButtonStyle(isActive: hasChanges))
        .disabled(!hasChanges || isSaving)
        .padding(.horizontal)
    }
    
    private var logoutButton: some View {
        Button(action: apiClient.logout) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Выйти из аккаунта")
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
    
    private var passwordChangeSheet: some View {
        NavigationStack {
            ChangePasswordView(
                newPassword: $newPassword,
                onSave: { [self] in
                    Task { await checkForChanges() }
                }
            )
            .environmentObject(apiClient)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("О себе")
                .font(.headline)
                .foregroundColor(.white)
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
            Button{ dismiss()
            }label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Назад")
                }
                .foregroundColor(orangeColor)
            }
        }
    }
    
    private func errorMessageView(_ error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(error)
        }
        .foregroundColor(.red)
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    // MARK: - Methods
    
    private func loadUserData() {
        Task {
            if let user = await apiClient.currentUser {
                username = user.username?.isEmpty ?? true ? "" : user.username ?? ""
                phoneNumber = user.phone_number?.isEmpty ?? true ? "" : user.phone_number ?? ""
                formattedPhoneNumber = formatPhoneNumber(phoneNumber)
            }
        }
    }
    
    private func checkForChanges() {
        Task {
            if let user = await apiClient.currentUser {
                let phoneChanged = !phoneNumber.isEmpty && phoneNumber != (user.phone_number ?? "")
                let usernameChanged = !username.isEmpty && username != (user.username ?? "")
                let passwordChanged = !newPassword.isEmpty
                
                hasChanges = usernameChanged || phoneChanged || passwordChanged
            }
        }
    }

    private func saveChanges() {
        Task {
            isSaving = true
            errorMessage = nil
            
            do {
                let updatedUser = try await apiClient.updateUserProfile(
                    username: username,
                    phoneNumber: phoneNumber,
                    currentPassword: currentPassword.isEmpty ? nil : currentPassword,
                    newPassword: newPassword.isEmpty ? nil : newPassword
                )

                try await withCheckedThrowingContinuation { continuation in
                    apiClient.fetchCurrentUser(completion: { result in
                        switch result {
                        case .success(let user):
                            continuation.resume(returning: user)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    })
                }
                
                await MainActor.run {
                    showSuccessAlert = true
                    onSave()
                    isSaving = false
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = handleError(error)
                    isSaving = false
                }
            }
        }
    }
    private func handleError(_ error: Error) -> String {
        if let error = error as? AuthError {
            switch error {
            case .currentPasswordRequired:
                return "Для смены пароля введите текущий пароль"
            case .invalidCredentials:
                return "Неверный текущий пароль"
            case .unauthorized:
                return "Требуется авторизация"
            case .invalidResponse:
                return "Что то там"
            @unknown default:
                return "Неизвестная ошибка"
            }
        } else if let error = error as? ValidationError {
            switch error {
            case .invalidPhoneNumber:
                return "Номер должен быть в формате +7XXXXXXXXXX"
            case .passwordTooShort:
                return "Пароль должен содержать минимум 5 символов"
            @unknown default:
                return "Неизвестная ошибка"
            
            }
        } else if let error = error as? NetworkError {
            switch error {
            case .nothingToUpdate:
                return "Нет изменений для сохранения"
            case .badRequest(let message):
                return "Ошибка запроса: \(message)"
            default:
                return "Сетевая ошибка"
            }
        }
        
        return "Ошибка при сохранении: \(error.localizedDescription)"
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

}

// MARK: - Styles

private struct ProfileFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .foregroundColor(.white)
    }
}

private struct SaveButtonStyle: ButtonStyle {
    let isActive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(isActive ? Color.orange : Color.gray)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// MARK: - Preview

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(onSave: {})
            .environmentObject(ApiClient())
    }
}
