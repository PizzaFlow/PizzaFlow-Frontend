//
//  PasswordVerificationresponse.swift
//  PizzaFlow
//
//  Created by 596 on 05.04.2025.
//

import Foundation

struct PasswordVerificationResponse: Codable {
    let isValid: Bool
}

struct ErrorResponse: Codable {
    let message: String
}

struct ValidationErrorResponse: Codable {
    let errors: [String: [String]]
}


enum ValidationError: Error {
    case invalidPhoneNumber
    case passwordTooShort
}

