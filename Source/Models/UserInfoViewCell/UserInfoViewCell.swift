//
//  InfoViewCell.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 30.04.2025.
//

import UIKit

class UserInfoViewCell: UITableViewCell {
    
    @IBOutlet weak var loginStatusViewContainer: UIView!
    @IBOutlet weak var subscribeViewContainer: UIView!
    @IBOutlet weak var subscribeLabel: UILabel!
    @IBOutlet weak var noHistoryView: UIView!
    @IBOutlet weak var noHistoryLabel: UILabel!
    @IBOutlet weak var zeroSpacingView: UIView!
    
    override func prepareForReuse() {
        self.loginStatusViewContainer.subviews.forEach { $0.removeFromSuperview() }
    }
    
    public func configureWithNotLoggedInView(onSignInTap: @escaping () -> Void, onSignUpTap: @escaping () -> Void) {
        guard let view = NotLoggedInView.loadFromNib() else { return }
        view.embedIn(self.loginStatusViewContainer)
        view.onSignInTapped = onSignInTap
        view.onSignUpTapped = onSignUpTap
        
        self.subscribeViewContainer.superview?.setCornerRadius()
        self.noHistoryView.superview?.setCornerRadius()
        
        self.subscribeLabel.text = "Автентифікуйтесь, щоб керувати підписками"
        self.noHistoryLabel.text = "Автентифікуйтесь, щоб бачити історію донатів"
        
        self.subscribeViewContainer.subviews.forEach { $0.isHidden = false }
        self.noHistoryView.superview?.isHidden = false
        self.zeroSpacingView.isHidden = true
    }
    
    public func configureWithLoggedInView(userImage: UIImage, userName: String, userSubscribeIsEmpty: Bool = true, userHistoryIsEmpty: Bool, logout: @escaping () -> Void) {
        guard let view = LoggedInView.loadFromNib() else { return }
        view.embedIn(self.loginStatusViewContainer)
        view.configure(userImage, userName)
        view.logout = logout
        
        self.subscribeViewContainer.superview?.setCornerRadius()
        self.noHistoryView.superview?.setCornerRadius()
        
        if userSubscribeIsEmpty {
            self.subscribeLabel.text = "Ви ще не маєте підписки"
        } else {
            self.subscribeViewContainer.subviews.forEach { $0.isHidden = true }
        }
        
        if userHistoryIsEmpty {
            self.noHistoryLabel.text = "Ви ще не здійснили жодного донату"
        } else {
            self.noHistoryView.superview?.isHidden = true
            self.zeroSpacingView.isHidden = false
        }
    }
}
