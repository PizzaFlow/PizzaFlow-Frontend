//
//  ApiClient.swift
//  PizzaFlow
//
//  Created by 596 on 05.03.2025.
//

import Foundation

class ApiClient: ObservableObject {
    @Published var pizzas: [Pizza] = []
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
        guard let url = URL(string: "http://localhost:8000/pizzas") else {return}
        
        var request = URLRequest(url: url)
        if let token = token {
            request.setValue("Bearer\(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                return
            }
            guard let  data = data else {
                print("Нет данных")
                return
            }
            do {
                let decodedData = try JSONDecoder().decode([Pizza].self, from: data)
                DispatchQueue.main.async {
                    self.pizzas = decodedData
                }
            } catch {
                print("Ошибка декодирования: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    func register(username: String, email: String, password: String, completion: @escaping(Bool, String?) -> Void) {
        guard let url = URL(string: "http://localhost:8000/registration") else {return}
        
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
        guard let url = URL(string: "http://localhost:8000/login") else {return}
        
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
