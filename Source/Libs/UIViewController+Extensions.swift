//
//  UIViewController+Extension.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 29.04.2025.
//

import UIKit

extension UIViewController {
    func enableHideKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnTap))
        tap.cancelsTouchesInView = false
        self.navigationController?.view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboardOnTap() {
        if let searchBar = self.navigationItem.titleView as? UISearchBar {
            searchBar.resignFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
}

extension UIViewController: UISearchBarDelegate {
    func setupSearchBarWithFilter(placeholder: String, filterAction: Selector) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.placeholder = placeholder
        searchBar.tintColor = .link
        searchBar.delegate = self
        
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease"),
            style: .plain,
            target: self,
            action: filterAction
        )
        
        self.navigationItem.titleView = searchBar
        self.navigationItem.rightBarButtonItem = filterButton
        
        return searchBar
    }
}

