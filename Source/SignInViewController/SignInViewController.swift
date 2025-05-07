//
//  SignIpViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 04.05.2025.
//

import UIKit
import FirebaseAuth

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
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let errorResult = ErrorService.getLocalizedError(from: error) {
                self.updateErrorLabels(with: errorResult)
                return
            }
            
            self.resetErrorLabels()
            self.navigationController?.popViewController(animated: true)
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
}
