//
//  FundraiserDetailsViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 06.01.2025.
//

import UIKit
import FirebaseFirestore

class FundraiserDetailsViewController: UIViewController {
    private var rootView: FundraiserDetailsView? {
        self.viewIfLoaded as? FundraiserDetailsView
    }
    
    private let fundraiser: FundraiserModel
    private var descriptionMediaNames: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rootView?.fillView(with: self.fundraiser)
        
        Task {
            await self.getDescriptionMediaNames()
            self.rootView?.fillMediaCollectionView(for: self.fundraiser.id, with: self.descriptionMediaNames)
        }
            
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    init(fundraiser: FundraiserModel) {
        self.fundraiser = fundraiser
        super.init(nibName: "FundraiserDetailsViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getDescriptionMediaNames() async {
        do {
            let db = Firestore.firestore()
            let document = try await db.collection("Fundraisers").document(self.fundraiser.id).getDocument()
            if let descriptionMediaArray = document.data()?["descriptionMedia"] as? [String] {
                self.descriptionMediaNames = descriptionMediaArray
            }
        } catch {
            print("Error fetching media names data: \(error)")
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let bottomInset = keyboardFrame.height
            self.rootView?.scrollView.contentInset.bottom = bottomInset
            self.rootView?.scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        self.rootView?.scrollView.contentInset.bottom = 0
        self.rootView?.scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
