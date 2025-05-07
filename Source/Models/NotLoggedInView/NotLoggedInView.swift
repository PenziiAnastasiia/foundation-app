//
//  NotLoggedInView.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 06.05.2025.
//

import UIKit

class NotLoggedInView: UIView {
    
    var onSignInTapped: (() -> Void)?
    var onSignUpTapped: (() -> Void)?
    
    @IBAction func didTappedSignIn() {
        self.onSignInTapped?()
    }
    
    @IBAction func didTappedSignUp() {
        self.onSignUpTapped?()
    }
}
