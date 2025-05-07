//
//  SignUpViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 04.05.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

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
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let errorResult = ErrorService.getLocalizedError(from: error) {
                self.currentFormView?.updateErrorLabels(with: errorResult)
                return
            }
            
            self.currentFormView?.resetErrorLabels()
            guard let uid = result?.user.uid,
                  let data = self.currentFormView?.getUserData()
            else { return }
            
            self.saveUserData(user: uid, data: data)
        }
    }
    
    private func saveUserData(user uid: String, data: [String: String]) {
        Firestore.firestore().collection("Users").document(uid).setData(data) { error in
            if error != nil {
                Auth.auth().currentUser?.delete { _ in }
                self.generalErrorView.isHidden = false
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - FormViewDelegate
    
    func didTapSignUp(email: String, password: String) {
        self.signUp(email: email, password: password)
    }
}
