//
//  AuthError.swift
//  PizzaFlow
//
//  Created by 596 on 04.04.2025.
//

import Foundation

enum AuthError: Error {
    case unauthorized
    case invalidCredentials
    case invalidResponse
    case currentPasswordRequired
}
