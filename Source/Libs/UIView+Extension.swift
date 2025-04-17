//
//  UIView+Extension.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 17.04.2025.
//

import UIKit


extension UIView {
    func parentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let vc = nextResponder as? UIViewController {
                return vc
            }
            responder = nextResponder
        }
        return nil
    }
}
