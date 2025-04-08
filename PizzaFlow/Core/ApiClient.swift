//
//  ApiClient.swift
//  PizzaFlow
//
//  Created by 596 on 05.03.2025.
//

import Foundation

actor UserState {
    private var _currentUser: User?
    
    func updateUser(_ update: (inout User?) -> Void) {
        update(&_currentUser)
    }
    
    func currentUser() -> User? {
        return _currentUser
    }
}


class ApiClient: ObservableObject {
    private let baseURL = "http://localhost:8000"
    private let userQueue = DispatchQueue(label: "user.access.queue", attributes: .concurrent)
    @Published var pizzas: [Pizza] = []
    @Published var ingridients: [Ingredient] = []
    @Published var favoritePizzas: [Pizza] = []
    @Published var pizzaIngredients: [Ingredient] = []
    @Published var addresses: [Address] = []
    @Published var orders: [OrderResponse] = []
    @Published var selectedAddress: Address?
    @Published var currentOrder: OrderResponse?
    private let userState = UserState()
    private let networkQueue = DispatchQueue(label: "network.queue", qos: .userInitiated)
    private var _currentUser: User?
    var currentUser: User? {
        get async {
            await userState.currentUser()
        }
    }
    
    @Published var token: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let token = self.token {
                    UserDefaults.standard.set(token, forKey: "authToken")
                } else {
                    UserDefaults.standard.removeObject(forKey: "authToken")
                }
            }
        }
    }
    
    init() {
        self.token = UserDefaults.standard.string(forKey: "authToken")
        fetchAddresses()
    }
    
    func movePizzaToTop(pizza: Pizza) {
        pizzas.removeAll { $0.id == pizza.id }
        pizzas.insert(pizza, at: 0)
    }

    func movePizzaToMainList(pizza: Pizza) {
        favoritePizzas.removeAll { $0.id == pizza.id }
        pizzas.append(pizza)
    }
    
    func fetchPizzas() {
        print("🔄 Вызван fetchPizzas()")
        guard let url = URL(string: "\(baseURL)/pizzas") else { return }
        
        var request = URLRequest(url: url)
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Ошибка: Сервер не дал ответа")
                return
            }

            print("🔹 Код ответа сервера: \(httpResponse.statusCode)")
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ Ошибка: Сервер вернул код \(httpResponse.statusCode)")
                return
            }
            guard let data = data else {
                print("Нет данных")
                return
            }
            
           

            do {
                print(String(data: data, encoding: .utf8) ?? "❌ Данные пустые!")
                let decodedData = try JSONDecoder().decode([Pizza].self, from: data)
                DispatchQueue.main.async {
                    self.pizzas = decodedData
                    print("✅ Загружено \(self.pizzas.count) пицц")
                    print(decodedData.isEmpty ? "⚠️ Сервер вернул пустой список пицц!" : "✅ Загружено \(decodedData.count) пицц")
                }
            } catch {
                print("Ошибка декодирования: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func fetchOrders() async throws {
        guard let token = token else {
            throw NetworkError.unauthorized
        }
        
        let url = URL(string: "\(baseURL)/users/orders/")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorData = String(data: data, encoding: .utf8) ?? ""
            print("Server error: \(errorData)")
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        do {
            let orders = try decoder.decode([OrderResponse].self, from: data)
            await MainActor.run {
                self.orders = orders
            }
        } catch {
            print("Decoding error: \(error)")
            throw error
        }
    }
    
    func fetchAddresses() {
        guard let url = URL(string: "\(baseURL)/users/address/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка загрузки адресов: \(error.localizedDescription)")
                return
            }
            guard let data = data else { return }
            do {
                let decodedData = try JSONDecoder().decode([Address].self, from: data)
                DispatchQueue.main.async {
                    print("Полученные адреса: \(decodedData)")
                    self.addresses = decodedData
                    if self.selectedAddress == nil, let firstAddress = decodedData.first {
                        self.selectedAddress = firstAddress
                    }
                }
            } catch {
                print("❌ Ошибка декодирования JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func addAddress(city: String, street: String, house: String, apartment: String, completion: @escaping (Bool, String?) -> Void) {
        guard let token = token else {
            completion(false, "Нет токена")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/users/address/") else { return }
        
        let requestBody: [String: String] = [
            "city": city,
            "street": street,
            "house": house,
            "apartment": apartment
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, "Ошибка: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(false, "Нет ответа от сервера")
                }
                return
            }
            
            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    print("✅ Адрес успешно добавлен!")
                    self.fetchAddresses()
                    completion(true, nil)
                }
            } else {
                DispatchQueue.main.async {
                    let errorMessage = "Ошибка: сервер вернул \(httpResponse.statusCode)"
                    completion(false, errorMessage)
                }
            }
        }.resume()
    }
    
    func deleteAddress(addressID: Int) {
        guard let token = token else {
            print("❌ Ошибка: нет токена авторизации")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/users/address/\(addressID)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("❌ Ошибка удаления адреса: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    print("❌ Ошибка: сервер не дал ответа")
                }
                return
            }
            
            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    print("✅ Адрес успешно удалён!")
                    self.addresses.removeAll { $0.id == addressID }
                }
            } else {
                DispatchQueue.main.async {
                    print("❌ Ошибка удаления: сервер вернул \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    func sendAddressToServer(city: String, street: String, house: String, apartment: String, completion: @escaping (Bool, String?) -> Void) {
        guard let token = token else {
            print("❌ Ошибка: нет токена авторизации")
            completion(false, "Нет токена")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/users/address/") else { return }
        
        let requestBody: [String: String] = [
            "city": city,
            "street": street,
            "house": house,
            "apartment": apartment
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("❌ Ошибка запроса: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    print("❌ Ошибка: сервер не дал ответа")
                    completion(false, "Нет ответа сервера")
                }
                return
            }
            
            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    print("✅ Адрес успешно добавлен!")
                    completion(true, nil)
                }
            } else {
                DispatchQueue.main.async {
                    let errorMessage = "Ошибка: сервер вернул \(httpResponse.statusCode)"
                    print("❌ \(errorMessage)")
                    completion(false, errorMessage)
                }
            }
        }.resume()
    }
    
    func createOrder(request: CreateOrderRequest) async throws -> OrderResponse {
        guard let token = token else {
            throw NetworkError.unauthorized
        }
        
        let url = URL(string: "\(baseURL)/orders/")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorData = String(data: data, encoding: .utf8) ?? ""
            print("Server error: \(errorData)")
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        
        do {
            let order = try decoder.decode(OrderResponse.self, from: data)
            print("Successfully decoded order: \(order)")
            return order
        } catch let decodingError as DecodingError {
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("Missing key: \(key.stringValue)")
                print("Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                print("Debug context: \(context.debugDescription)")
                print("Full response: \(String(data: data, encoding: .utf8) ?? "No data")")
                throw decodingError
            default:
                print("Decoding error: \(decodingError.localizedDescription)")
                throw decodingError
            }
        } catch {
            print("Unknown error: \(error)")
            throw error
        }
    }
    
    func fetchAllIngredients() {
        guard let url = URL(string: "\(baseURL)/ingredients") else { return }
        
        var request = URLRequest(url: url)
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка запроса ингредиентов: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("❌ Нет данных от сервера")
                return
            }
            do {
                let decodedData = try JSONDecoder().decode([Ingredient].self, from: data)
                DispatchQueue.main.async {
                    self.ingridients = decodedData
                }
            } catch {
                print("❌ Ошибка декодирования JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func fetchFavoritePizzas(completion: @escaping (Bool, String?) -> Void) {
        guard let token = token, !token.isEmpty else {
            print("❌ Ошибка: токен отсутствует!")
            completion(false, "❌ Токен отсутствует")
            return
        }
        guard let url = URL(string: "\(baseURL)/users/favorite-pizzas/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("❌ Ошибка запроса избранных пицц: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                }
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("🔹 Код ответа сервера: \(httpResponse.statusCode)")
            }
            guard let data = data else {
                print("Нет данных")
                return
            }
            
            guard !data.isEmpty else {
                print("⚠️ Сервер вернул пустой массив")
                return
            }
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode([Pizza].self, from: data)
                
                DispatchQueue.main.async {
                    self.favoritePizzas = decodedData
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    print("❌ Ошибка декодирования JSON: \(error.localizedDescription)")
                    completion(false, "Ошибка обработки данных")
                }
            }
        }
        task.resume()
    }
    
    func fetchDeliveryTimes() async throws -> [DeliveryTime] {
        guard let token = token else {
            throw NetworkError.unauthorized
        }
        
        let url = URL(string: "\(baseURL)/orders/delivery-times/")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            let response = try JSONDecoder().decode(DeliveryTimesResponse.self, from: data)
            return response.deliveryTimes.map { DeliveryTime(timeRange: $0, day: .today) }
        } catch {
            print("Ошибка декодирования: \(error)")
            print("Ответ сервера: \(String(data: data, encoding: .utf8) ?? "неизвестно")")
            throw error
        }
    }
    
    func addPizzaToFavorites(pizzaID: Int, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/favorite-pizzas/\(pizzaID)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка добавления в избранное: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.fetchFavoritePizzas { success, error in
                    if success {
                        print("✅ Избранные пиццы успешно загружены!")
                    } else {
                        print("❌ Ошибка загрузки избранных пицц: \(error ?? "Неизвестная ошибка")")
                    }
                }
            }
        }
        task.resume()
    }
    
    func removePizzaFromFavorites(pizzaID: Int, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/favorite-pizzas/\(pizzaID)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(false, "❌ Ошибка ответа сервера")
                }
                return
            }
            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } else {
                completion(false, "❌ Ошибка удаления, код: \(httpResponse.statusCode)")
            }
        }.resume()
    }

    func register(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        let url = URL(string: "\(baseURL)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let requestBody = ["email": email, "password": password]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    completion(false, error.localizedDescription)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    completion(false, "Ошибка сервера")
                    return
                }
                
                DispatchQueue.main.async {
                    let newUser = User(id: 0, username: "", phone_number: "", email:"")
                    Task {
                        await self?.userState.updateUser { $0 = newUser }
                        completion(true, nil)
                    }
                }
            }.resume()
        } catch {
            completion(false, "Ошибка формирования запроса")
        }
    }
   
    func updateUserProfile(
        username: String? = nil,
        phoneNumber: String? = nil,
        currentPassword: String? = nil,
        newPassword: String? = nil
    ) async throws -> User {
        guard let token = token else {
            throw AuthError.unauthorized
        }
        
        // Валидация только тех полей, которые действительно изменяются
        if let phone = phoneNumber, !phone.isEmpty {
            guard isValidRussianPhoneNumber(phone) else {
                throw ValidationError.invalidPhoneNumber
            }
        }
        
        if let newPass = newPassword, !newPass.isEmpty {
            guard newPass.count >= 5 else {
                throw ValidationError.passwordTooShort
            }
            guard currentPassword != nil else {
                throw AuthError.currentPasswordRequired
            }
        }
        var requestBody = [String: Any]()
        
        if let username = username {
            requestBody["username"] = username
        }
        
        if let phone = phoneNumber, !phone.isEmpty {
            requestBody["phone_number"] = phone
        }
        
        if let newPass = newPassword, !newPass.isEmpty {
            requestBody["current_password"] = currentPassword
            requestBody["new_password"] = newPass
        }
        
        guard !requestBody.isEmpty else {
            throw NetworkError.nothingToUpdate
        }
        
        // Остальная часть метода остается без изменений
        guard let url = URL(string: "\(baseURL)/users/me") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                return try JSONDecoder().decode(User.self, from: data)
                
            case 400:
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw NetworkError.badRequest(message: errorResponse.message)
                
            case 401:
                throw AuthError.unauthorized
                
            case 422:
                let errorResponse = try JSONDecoder().decode(ValidationErrorResponse.self, from: data)
                throw NetworkError.validationFailed(errors: errorResponse.errors)
                
            default:
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
        } catch {
            throw error
        }
    }
        
        private func isValidRussianPhoneNumber(_ phone: String) -> Bool {
            let regex = #"^\+7\d{10}$"#
            return phone.range(of: regex, options: .regularExpression) != nil
        }
        
        func changePassword(newPassword: String) async throws -> Bool {
            guard let userId = await currentUser?.id else {
                throw AuthError.unauthorized
            }
            
            guard let url = URL(string: "\(baseURL)/users/me") else {
                throw NetworkError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let token = token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            let requestBody: [String: Any] = [
                "password": newPassword
            ]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            } catch {
                throw NetworkError.encodingFailed
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Неизвестная ошибка"
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool {
                return success
            }
            
            return true
        }
        
    func updateCurrentUser(_ update: @escaping (inout User?) -> Void) {
        userQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            update(&self._currentUser)
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
        func fetchCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {
        guard let token = token else {
            completion(.failure(AuthError.unauthorized))
            return
        }
        
        let url = URL(string: "\(baseURL)/users/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(AuthError.invalidResponse))
                return
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                Task {
                    await self?.userState.updateUser { $0 = user }
                    DispatchQueue.main.async {
                        self?.objectWillChange.send()
                        completion(.success(user))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func verifyPassword(_ password: String) async throws -> Bool {
        guard let token = token else {
            throw AuthError.unauthorized
        }
        
        guard let url = URL(string: "\(baseURL)/auth/verify-password") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let requestBody = ["password": password]
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decodedResponse = try JSONDecoder().decode(PasswordVerificationResponse.self, from: data)
            return decodedResponse.isValid
        case 401:
            throw AuthError.unauthorized
        case 403:
            return false
        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }

    
    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            completion(false, "Неверный URL")
            return
        }
        
        let requestBody = ["email": email, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            completion(false, "Ошибка формирования запроса")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(false, "Некорректный ответ сервера")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, "Нет данных в ответе")
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.token = decodedResponse.access_token
                    self.fetchCurrentUser { result in
                        switch result {
                        case .success:
                            completion(true, nil)
                        case .failure(let error):
                            completion(false, error.localizedDescription)
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Ошибка декодирования ответа")
                }
            }
        }.resume()
    }
    
    func logout() {
        token = nil
    }
}

