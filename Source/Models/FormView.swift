//
//  FormView.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 06.05.2025.
//

import UIKit

protocol FormView: AnyObject {
    var delegate: FormViewDelegate? { get set }

    func configure()
    func getScrollView() -> UIScrollView?
    func getUserData() -> [String: String]?
    func updateErrorLabels(with result: AuthErrorResult)
    func resetErrorLabels()
}

protocol FormViewDelegate: AnyObject {
    func didTapSignUp(email: String, password: String)
}
