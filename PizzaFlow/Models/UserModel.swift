//
//  UserModel.swift
//  PizzaFlow
//
//  Created by 596 on 02.04.2025.
//

import Foundation

struct User: Codable, Identifiable {
    var id: Int
    var username: String?
    var phone_number: String?
    var email: String
    
    init(id: Int, username: String? = nil, phone_number: String? = nil, email: String) {
        self.id = id
        self.username = username
        self.phone_number = phone_number
        self.email = email
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        phone_number = try container.decodeIfPresent(String.self, forKey: .phone_number)
    }
    
    static var empty: User {
        User(id: 0, email: "")
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email, username, phone_number
    }
}
