//
//  UserModel.swift
//  PizzaFlow
//
//  Created by 596 on 02.04.2025.
//

import Foundation
struct User: Codable, Identifiable {
    var id: Int
    var username: String
    var phone_number: String
    var email: String
    
    static var empty: User {
        User(id: 0, username: "", phone_number: "", email: "")
    }
}
