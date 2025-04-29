//
//  KeyboardObservable.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 29.04.2025.
//

import UIKit

protocol KeyboardObservable: AnyObject {
    var scrollViewToAdjust: UIScrollView? { get }
    func startObservingKeyboard()
    func stopObservingKeyboard()
}

extension KeyboardObservable where Self: UIViewController {
    func startObservingKeyboard() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
            guard let scrollView = self?.scrollViewToAdjust,
                  let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
            scrollView.contentInset.bottom = keyboardFrame.height
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            guard let scrollView = self?.scrollViewToAdjust else { return }
            scrollView.contentInset.bottom = 0
            scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }

    func stopObservingKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
