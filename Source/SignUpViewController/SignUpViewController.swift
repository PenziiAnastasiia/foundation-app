//
//  SignUpViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 04.05.2025.
//

import UIKit

class SignUpViewController: UIViewController, KeyboardObservable, FormViewDelegate {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var generalErrorView: UIView!
    @IBOutlet weak var formContainer: UIView!

    var scrollViewToAdjust: UIScrollView? {
        return currentFormScrollView
    }
    
    private var currentFormView: (UIView & FormView)?
    private var currentFormScrollView: UIScrollView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enableHideKeyboardOnTap()
        self.startObservingKeyboard()
        
        if let formView = IndividualFormView.loadFromNib() {
            self.addFormIntoContainer(formView: formView)
        }
    }
    
    deinit {
        self.stopObservingKeyboard()
    }
    
    @IBAction func segmentControlAction(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            if let formView = IndividualFormView.loadFromNib() {
                self.addFormIntoContainer(formView: formView)
            }
        case 1:
            if let formView = LegalEntityForm.loadFromNib() {
                self.addFormIntoContainer(formView: formView)
            }
        default:
            if let formView = IndividualFormView.loadFromNib() {
                self.addFormIntoContainer(formView: formView)
            }
        }
    }
    
    // MARK: - private
    
    private func addFormIntoContainer(formView: (UIView & FormView)) {
        formView.configure()
        formView.delegate = self
        formView.embedIn(self.formContainer)
        self.currentFormView = formView
        self.currentFormScrollView = formView.getScrollView()
    }
    
    private func signUp(email: String, password: String) {
        AuthService.shared.signUp(email: email, password: password) { result in
            switch result {
            case .success(let uid):
                self.currentFormView?.resetErrorLabels()
                guard let user = self.currentFormView?.getUser() else { return }
                self.saveUserData(uid, user)

            case .failure(let error):
                if let errorResult = ErrorService.getLocalizedError(from: error) {
                    self.currentFormView?.updateErrorLabels(with: errorResult)
                }
            }
        }
    }
    
    private func saveUserData(_ uid: String, _ user: UserModel) {
        AuthService.shared.saveUserData(uid, user) { result in
            switch result {
            case .success:
                UserManager.shared.saveUserToDefaults(user, uid: uid)
                self.navigationController?.popViewController(animated: true)
                
            case .failure(let error):
                AuthService.shared.deleteUser()
                self.showAlert(title: "Невідома помилка", message: "Повторіть спробу регістрації пізніше")
            }
        }
    }
    
    // MARK: - FormViewDelegate
    
    func didTapSignUp(email: String, password: String) {
        self.signUp(email: email, password: password)
    }
}
