//
//  PizzaModel.swift
//  PizzaFlow
//
//  Created by 596 on 05.03.2025.
//

struct Pizza: Codable, Identifiable {
    let id: Int
    let name: String
    let price: Double
    let description: String
    let photo: String
}
