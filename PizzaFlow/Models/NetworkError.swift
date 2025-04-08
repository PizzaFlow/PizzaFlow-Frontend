//
//  NetworkError.swift
//  PizzaFlow
//
//  Created by 596 on 28.03.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case unauthorized
    case decodingError
    case invalidResponse
    case serverError(statusCode: Int)
    case badRequest(message: String)
    case validationFailed(errors: [String: [String]])
    case nothingToUpdate
    case encodingFailed
    case addressNotFound
}
