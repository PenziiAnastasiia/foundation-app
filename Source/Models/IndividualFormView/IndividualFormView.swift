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
    @IBOutlet weak var button: UIButton!
    
    private var changingMode: Bool = false
    
    func getScrollView() -> UIScrollView? {
        return nil
    }

    @IBAction func didTappedButton() {
        if !self.getResultOfAllChecks() { return }
        
        guard let user = self.getUser() else { return }

        if self.changingMode {
            self.delegate?.didTapSave(user: user)
        } else {
            guard let email = self.emailTextField.text,
                  let password = self.passwordTextField.text else { return }
            
            self.delegate?.didTapSignUp(email: email, password: password, user: user)
        }
    }
    
    public func configure(changingMode: Bool = false) {
        [self.PIBTextField, self.emailTextField, self.passwordTextField].forEach { textField in
            textField.applyStandardStyle()
        }
        if changingMode {
            self.configureChangingModeView()
        }
        self.changingMode = changingMode
    }
    
    public func updateErrorLabels(with errorResult: AuthErrorResult) {
        self.emailErrorLabel.text = errorResult.textEmailError
        self.passwordErrorLabel.text = errorResult.textPasswordError
    }
    
    public func resetErrorLabels() {
        self.emailErrorLabel.text = ""
        self.passwordErrorLabel.text = ""
    }
    
    // MARK: - private
    
    private func configureChangingModeView() {
        guard let user = UserManager.shared.currentUser else { return }
        self.PIBTextField.text = user.PIB
        self.emailTextField.superview?.isHidden = true
        self.passwordTextField.superview?.isHidden = true
        let attributedTitle = NSAttributedString(
            string: "Зберегти",
            attributes: [
                .font: UIFont.systemFont(ofSize: 20, weight: .regular)
            ]
        )
        self.button.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    private func getResultOfAllChecks() -> Bool {
        let checkPIBResult = self.PIBTextField.checkPIB()

        if changingMode {
            return checkPIBResult
        }

        let checkEmailResult = self.emailTextField.validateEmail()
        let checkPassword = self.passwordTextField.isNotEmpty

        return checkPIBResult && checkEmailResult && checkPassword
    }
    
    private func generateEmoji() -> String {
        let emojiArray = ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐻‍❄️", "🐨", "🐯", "🦁",
                          "🐮", "🐷", "🐸", "🐵", "🐥", "🦉", "🐺", "🦄", "🐝", "🦋", "🐬", "🐙"]
        return emojiArray.randomElement() ?? "🙂"
    }
    
    private func getUser() -> UserModel? {
        guard let pib = self.PIBTextField.text else { return nil }
        let currentEmoji = UserManager.shared.currentUser?.emoji ?? self.generateEmoji()

        return try? UserModel.fromDictionary([
            "PIB": pib,
            "emoji": currentEmoji,
            "type": "individual"
        ])
    }
}
