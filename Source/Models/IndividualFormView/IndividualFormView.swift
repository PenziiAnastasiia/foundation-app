//
//  IndividualFormView.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 04.05.2025.
//

import Foundation
import UIKit

class IndividualFormView: UIView, FormView {
    
    weak var delegate: FormViewDelegate?
    
    @IBOutlet weak var PIBTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    func getScrollView() -> UIScrollView? {
        return nil
    }

    @IBAction func didTappedSignUp() {
        if !self.getResultOfAllChecks() { return }
        guard let email = self.emailTextField.text, let password = self.passwordTextField.text else { return }
        
        self.delegate?.didTapSignUp(email: email, password: password)
    }
    
    public func configure() {
        [self.PIBTextField, self.emailTextField, self.passwordTextField].forEach { textField in
            textField.applyStandardStyle()
        }
    }
    
    public func updateErrorLabels(with errorResult: AuthErrorResult) {
        self.emailErrorLabel.text = errorResult.textEmailError
        self.passwordErrorLabel.text = errorResult.textPasswordError
    }
    
    public func resetErrorLabels() {
        self.emailErrorLabel.text = ""
        self.passwordErrorLabel.text = ""
    }
    
    public func getUser() -> UserModel? {
        guard let pib = self.PIBTextField.text else { return nil }
        let emoji = self.generateEmoji()
        
        return UserModel(PIB: pib, emoji: emoji, type: "individual")
    }
    
    // MARK: - private
    
    private func getResultOfAllChecks() -> Bool {
        let checkPIBResult = self.PIBTextField.checkPIB()
        let checkEmailResult = self.emailTextField.validateEmail()
        let checkPassword = self.passwordTextField.isNotEmpty
        
        return checkPIBResult && checkEmailResult && checkPassword
    }
    
    private func generateEmoji() -> String {
        let emojiArray = ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐻‍❄️", "🐨", "🐯", "🦁",
                          "🐮", "🐷", "🐸", "🐵", "🐥", "🦉", "🐺", "🦄", "🐝", "🦋", "🐬", "🐙"]
        return emojiArray.randomElement() ?? "🙂"
    }
}
