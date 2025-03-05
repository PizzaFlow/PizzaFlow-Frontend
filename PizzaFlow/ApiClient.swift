//
//  ApiClient.swift
//  PizzaFlow
//
//  Created by 596 on 05.03.2025.
//

import Foundation

class ApiClient: ObservableObject {
    @Published var pizzas: [Pizza] = []
    
    func fetchPizzas() {
        guard let url = URL(string: "http://localhost:8000/pizzas") else {return}
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
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
}
