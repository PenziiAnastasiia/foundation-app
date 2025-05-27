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
    
    static func loadFromNib() -> Self? {
        let nibName = String(describing: self)
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil).first as? Self
    }
    
    func setCornerRadius(value: CGFloat? = nil) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = value ?? 16
        self.clipsToBounds = true
    }
    
    func embedIn(_ container: UIView, constant: CGFloat = 0.0) {
        container.subviews.forEach { $0.removeFromSuperview() }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(self)
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.topAnchor.constraint(equalTo: container.topAnchor, constant: constant),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -constant)
        ])
    }
    
    func embedInSafeArea(of container: UIView) {
        container.subviews.forEach { $0.removeFromSuperview() }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(self)
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leadingAnchor),
            self.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 16),
            self.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
