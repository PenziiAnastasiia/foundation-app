//
//  AuthErrorService.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 06.05.2025.
//

import Foundation
import FirebaseAuth

public struct AuthErrorResult {
    let textEmailError: String
    let textPasswordError: String
}

public struct ErrorService {
    public static func getLocalizedError(from error: Error?) -> AuthErrorResult? {
        guard let error = error else { return nil } 
        
        var emailError = ""
        var passwordError = ""
        
        switch AuthErrorCode(rawValue:(error as NSError).code) {
        case .invalidEmail:
            emailError = "Некоректний email"
        case .emailAlreadyInUse:
            emailError = "Цей email вже зареєстрований"
        case .wrongPassword, .invalidCredential:
            passwordError = "Неправильний пароль"
        case .weakPassword:
            passwordError = "Пароль має містити мінімум 6 символів"
        default:
            emailError = "Виникла невідома помилка"
            passwordError = "Повторіть спробу пізніше"
        }
        
        return AuthErrorResult(textEmailError: emailError, textPasswordError: passwordError)
    }
}
