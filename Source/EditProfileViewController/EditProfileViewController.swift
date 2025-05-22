//
//  EditProfileViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 22.05.2025.
//

import Foundation
import UIKit

class EditProfileViewController: UIViewController, KeyboardObservable, FormViewDelegate {
    
    var scrollViewToAdjust: UIScrollView? {
        self.formView?.getScrollView()
    }
    
    private var formView: (UIView & FormView)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .background
        
        self.enableHideKeyboardOnTap()
        self.startObservingKeyboard()
        
        guard let user = UserManager.shared.currentUser else { return }

        switch user.type {
        case "individual":
            self.formView = IndividualFormView.loadFromNib()
        case "legal":
            self.formView = LegalEntityFormView.loadFromNib()
        default:
            return
        }

        guard let formView = self.formView else { return }
        formView.configure(changingMode: true)
        formView.delegate = self
        formView.embedInSafeArea(of: self.view)
    }
    
    deinit {
        self.stopObservingKeyboard()
    }
    
    // MARK: - FormViewDelegate
    
    func didTapSignUp(email: String, password: String, user: UserModel) { }
    
    func didTapSave(user: UserModel) {
        guard let uid = UserManager.shared.currentUID else { return }
        AuthService.shared.saveUserData(uid, user) { result in
            switch result {
            case .success:
                UserManager.shared.saveUserData(user, uid: uid)
                self.navigationController?.popViewController(animated: true)
                
            case .failure(_):
                AuthService.shared.deleteUser()
                self.showAlert(title: "Невідома помилка", message: "Повторіть спробу регістрації пізніше")
            }
        }
    }
}
