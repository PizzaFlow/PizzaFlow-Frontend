//
//  ApiClient.swift
//  PizzaFlow
//
//  Created by 596 on 05.03.2025.
//

import Foundation

class ApiClient: ObservableObject {
    private let baseURL = "http://localhost:8000"
    @Published var pizzas: [Pizza] = []
    @Published var ingridients: [Ingredient] = []
    @Published var favoritePizzas: [Pizza] = []
    @Published var pizzaIngredients: [Ingredient] = []
    @Published var token: String? {
        didSet{
            if let token = token {
                UserDefaults.standard.set(token, forKey: "authToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "authToken")
            }
        }
    }
    init(){
        self.token = UserDefaults.standard.string(forKey: "authToken")
    }
    
    func fetchPizzas() {
        print("🔄 Вызван fetchPizzas()")
        guard let url = URL(string: "\(baseURL)/pizzas") else {return}
        
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
            guard let  data = data else {
                print("Нет данных")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📜 Ответ сервера (RAW): \(jsonString)")
            }

            do {
                print("📜 Перед декодированием JSON:")
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
        guard let url = URL(string: "\(baseURL)/users/favorite-pizzas/") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("❌ Ошибка запроса избранных пицц: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                    return
                }
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("🔹 Код ответа сервера: \(httpResponse.statusCode)")
            }
            guard let data = data else {
                print("Нет данных")
                return
            }
            if let responseString = String(data: data, encoding: .utf8) {
                print("📜 Ответ сервера (RAW): \(responseString)")
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
    
    func addPizzatoFavorites(pizzaID: Int, completion: @escaping (Bool, String?) -> Void){
        guard let url = URL(string: "\(baseURL)/users/favorite-pizzas/\(pizzaID)") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка добавления в избранное : \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.fetchFavoritePizzas { succes, error in
                    if succes {
                        print("✅ Избранные пиццы успешно загружены!")
                    } else {
                        print("❌ Ошибка загрузки избранных пицц: \(error ?? "Неизвестная ошибка")")
                    }
                }
            }
        }
        task.resume()
    }
    
    func removePizzaFromFavorites(pizzaID: Int, completion: @escaping(Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/favorite-pizzas/\(pizzaID)") else {return}
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

    
   
    func register(username: String, email: String, password: String, completion: @escaping(Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/register") else {return}
        
        let requestBody = ["username": username, "email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
                
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
                return
            }
            guard let data = data else{
                DispatchQueue.main.async {
                    completion(false, "Нет данных о сервере")
                }
                return
            }
            DispatchQueue.main.async {
                completion(true, nil)
            }
        }.resume()
    }
    
    func login(email: String, password: String, completion: @escaping(Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/login") else {return}
        
        let requestBody = ["email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
            request.httpBody = jsonData
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("ОТправляемый Json: \(jsonString)")
            }
        } catch {
            print("❌ Ошибка создания JSON: \(error.localizedDescription)")
            completion(false, "Ошибка формирования запроса")
            return
        }
        print("URL запроса: \(request.url!.absoluteString)")
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("❌ Ошибка запроса: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                }
                return
            }
            guard let data = data else{
                DispatchQueue.main.async {
                    print("❌ Сервер не отвечает")
                    completion(false, "Нет данных о сервере")
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(false, "❌ Сервер не отвечает")
                }
                return
            }
            print("🔹 Код ответа сервера: \(httpResponse.statusCode)")

            if data.isEmpty {
                DispatchQueue.main.async {
                    completion(false, "❌ Нет данных в ответе")
                }
                return
            }

            if httpResponse.statusCode == 401 {
                DispatchQueue.main.async {
                    completion(false, "❌ Неверный логин или пароль")
                }
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                DispatchQueue.main.async {
                    self.token = decodedResponse.access_token
                    print("✅ Успешный вход. Токен: \(decodedResponse.access_token)")
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    print("❌ Ошибка декодирования JSON: \(error.localizedDescription)")
                    completion(false, "Ошибка авторизации")
                }
            }
        }.resume()
    }
    func logout() {
        token = nil
    }
}
