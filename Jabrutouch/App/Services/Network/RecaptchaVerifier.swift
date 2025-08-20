//
//  RecaptchaVerifier.swift
//  Jabrutouch
//
//  Created by ECH on 24/02/25.
//  Copyright © 2025 Ravtech. All rights reserved.
//


import Foundation

// MARK: - Errores de reCAPTCHA
enum RecaptchaError: Error {
    case networkError
    case invalidResponse
    case invalidData
    case jsonParsingError
    case recaptchaFailed
    case tooManyRequests
    
    var localizedDescription: String {
        switch self {
        case .networkError: return "Error de conexión con el servidor"
        case .invalidResponse: return "Respuesta inválida del servidor"
        case .invalidData: return "Datos inválidos recibidos"
        case .jsonParsingError: return "Error al procesar la respuesta del servidor"
        case .recaptchaFailed: return "reCAPTCHA falló, intenta nuevamente"
        case .tooManyRequests: return "Demasiadas solicitudes, intenta más tarde"
        }
    }
}
