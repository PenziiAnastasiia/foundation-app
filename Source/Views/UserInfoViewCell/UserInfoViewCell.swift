//
//  InfoViewCell.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 30.04.2025.
//

import UIKit

class UserInfoViewCell: UITableViewCell {
    
    @IBOutlet weak var loginStatusViewContainer: UIView!
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
        
        self.noHistoryView.superview?.setCornerRadius()
        self.noHistoryLabel.text = "Автентифікуйтесь, щоб бачити історію донатів"
        self.noHistoryView.superview?.isHidden = false
        self.zeroSpacingView.isHidden = true
    }
    
    public func configureWithLoggedInView(userEmoji: String, userName: String, userSubscribeIsEmpty: Bool = true, userHistoryIsEmpty: Bool, changeData: @escaping (() -> Void), logout: @escaping (() -> Void)) {
        guard let view = LoggedInView.loadFromNib() else { return }
        view.embedIn(self.loginStatusViewContainer)
        view.configure(userEmoji, userName)
        view.changeData = changeData
        view.logout = logout
        
        self.noHistoryView.superview?.setCornerRadius()
        
        if userHistoryIsEmpty {
            self.noHistoryLabel.text = "Ви ще не здійснили жодного донату"
        } else {
            self.noHistoryView.superview?.isHidden = true
            self.zeroSpacingView.isHidden = false
        }
    }
}
