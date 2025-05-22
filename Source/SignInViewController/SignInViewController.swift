//
//  SignIpViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 04.05.2025.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        [self.emailTextField, self.passwordTextField].forEach { textField in
            textField.applyStandardStyle()
        }
    }
    
    @IBAction func didTappedSignIn() {
        if !self.getResultOfAllChecks() { return }
        guard let email = self.emailTextField.text, let password = self.passwordTextField.text else { return }
        
        self.signIn(email: email, password: password)
    }
    
    // MARK: - private

    private func getResultOfAllChecks() -> Bool {
        let checkEmailResult = self.emailTextField.validateEmail()
        let checkPassword = self.passwordTextField.isNotEmpty
        
        return checkEmailResult && checkPassword
    }
    
    private func signIn(email: String, password: String) {
        AuthService.shared.signIn(email: email, password: password) { result in
            switch result {
            case .success(let uid):
                self.resetErrorLabels()
                Task {
                    await self.getUserData(uid)
                    self.navigationController?.popViewController(animated: true)
                }
            case.failure(let error):
                if let errorResult = ErrorService.getLocalizedError(from: error) {
                    self.updateErrorLabels(with: errorResult)
                }
            }
        }
    }
    
    private func updateErrorLabels(with errorResult: AuthErrorResult) {
        self.emailErrorLabel.text = errorResult.textEmailError
        self.passwordErrorLabel.text = errorResult.textPasswordError
    }
    
    private func resetErrorLabels() {
        self.emailErrorLabel.text = ""
        self.passwordErrorLabel.text = ""
    }
    
    private func getUserData(_ uid: String) async {
        do {
            let data = try await AuthService.shared.getUserData(uid)
            UserManager.shared.saveUserData(try UserModel.fromDictionary(data), uid: uid)
        } catch {
            AuthService.shared.signOut { _ in }
            self.showAlert(title: "Невідома помилка", message: "Повторіть спробу входу пізніше")
        }
    }
}
