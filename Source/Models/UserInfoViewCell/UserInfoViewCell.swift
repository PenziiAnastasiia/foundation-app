//
//  InfoViewCell.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 30.04.2025.
//

import UIKit

class UserInfoViewCell: UITableViewCell {
    
    @IBOutlet weak var loginStatusViewContainer: UIView!
    
    override func prepareForReuse() {
        self.loginStatusViewContainer.subviews.forEach { $0.removeFromSuperview() }
    }
    
    public func configureWithNotLoggedInView(onSignInTap: @escaping () -> Void, onSignUpTap: @escaping () -> Void) {
        guard let view = NotLoggedInView.loadFromNib() else { return }
        view.embedIn(self.loginStatusViewContainer)
        view.onSignInTapped = onSignInTap
        view.onSignUpTapped = onSignUpTap
    }
    
    public func configureWithLoggedInView(userImage: UIImage, userName: String, logout: @escaping () -> Void) {
        guard let view = LoggedInView.loadFromNib() else { return }
        view.embedIn(self.loginStatusViewContainer)
        view.configure(userImage, userName)
        view.logout = logout
    }
}
