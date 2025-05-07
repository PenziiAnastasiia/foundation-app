//
//  UITextField.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 05.05.2025.
//

import UIKit

extension UITextField {
    var isNotEmpty: Bool {
        guard let text = self.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            self.layer.borderColor = UIColor.red.cgColor
            return false
        }
        self.layer.borderColor = UIColor.gray.cgColor
        return true
    }
    
    func applyStandardStyle() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 8
    }
    
    func checkPIB() -> Bool {
        let components = self.text?.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        if !(components?.count == 3) {
            self.layer.borderColor = UIColor.red.cgColor
            return false
        }
        self.layer.borderColor = UIColor.gray.cgColor
        return true
    }
    
    func validateEmail() -> Bool {
        guard let text = self.text, text.isValidEmail else {
            self.layer.borderColor = UIColor.red.cgColor
            return false
        }
        self.layer.borderColor = UIColor.gray.cgColor
        return true
    }
}
