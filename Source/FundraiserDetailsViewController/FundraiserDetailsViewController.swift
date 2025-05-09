//
//  FundraiserDetailsViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 06.01.2025.
//

import UIKit

class FundraiserDetailsViewController: UIViewController, KeyboardObservable {
    
    private var rootView: FundraiserDetailsView? {
        self.viewIfLoaded as? FundraiserDetailsView
    }
    
    var scrollViewToAdjust: UIScrollView? {
        return self.rootView?.scrollView
    }
    
    private let fundraiser: FundraiserModel

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = UserManager.shared.currentUser
        
        if user?.type == nil || user?.type == "individual" {
            self.rootView?.fillView(with: self.fundraiser, donateFunc: self.donate)
        } else {
            self.rootView?.fillView(with: self.fundraiser, generateInvoiceFunc: self.generateInvoice)
        }

        self.rootView?.fillMediaCollectionView(for: self.fundraiser)
        self.enableHideKeyboardOnTap()
    }
    
    init(fundraiser: FundraiserModel) {
        self.fundraiser = fundraiser
        super.init(nibName: "FundraiserDetailsViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.startObservingKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopObservingKeyboard()
    }
    
    private func generateInvoice(_ sum: Double) {
        
    }
                                
    private func donate(_ sum: Double, _ cardNumber: Int?, _ expiredIn: Date?, _ CVV2: Int?) {
        if cardNumber == 0 {
            self.presentDonateResultViewController(success: false)
            return
        }
        
        let donation = DonationModel(fundraiser: self.fundraiser.id, amount: sum, date: Date())
        
        DonateService.shared.updateFundraiserCollectedValue(donation: donation) { result in
            switch result {
            case .success:
                if let uid = UserManager.shared.currentUID {
                    self.saveToHistory(uid: uid, donation: donation)
                }
                self.presentDonateResultViewController(success: true)
            case .failure(_):
                self.presentDonateResultViewController(success: false)
            }
        }
    }
    
    private func saveToHistory(uid: String, donation: DonationModel) {
        DonateService.shared.saveDonateToUserHistory(uid: uid, donation: donation) { result in
            switch result {
            case .success:
                print("success saved donation into history")
            case .failure:
                print("saving donation into history failed")
            }
        }
    }
    
    private func presentDonateResultViewController(success: Bool) {
        let controller = DonateResultViewController(success: success, fundraiserTitle: self.fundraiser.title)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
