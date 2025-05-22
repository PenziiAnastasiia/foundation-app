//
//  FundraiserDetailsViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 06.01.2025.
//

import UIKit

class FundraiserDetailsViewController: UIViewController, KeyboardObservable, UIDocumentInteractionControllerDelegate {
    
    private var rootView: FundraiserDetailsView? {
        self.viewIfLoaded as? FundraiserDetailsView
    }
    
    var scrollViewToAdjust: UIScrollView? {
        return self.rootView?.scrollView
    }
    
    private var docController: UIDocumentInteractionController?
    private let fundraiser: FundraiserModel
    private var donationSum: Double?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.rootView?.fillView(with: self.fundraiser)
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
        let user = UserManager.shared.currentUser
        if user?.type == "legal" {
            self.rootView?.fillDonateView(generateInvoiceFunc: self.generateInvoice)
        } else {
            self.rootView?.fillDonateView(donateFunc: self.makeDonation)
        }
        
        self.startObservingKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopObservingKeyboard()
    }
    
    private func makeDonation(_ sum: Double) {
        self.donationSum = sum
        self.donate()
    }
    
    private func generateInvoice(_ sum: Double) {
        PDFGeneratorService.generateInvoice(amount: sum, fundraiser: self.fundraiser.title) { url in
            guard let url = url else { return }
            
            self.donationSum = sum
            
            DispatchQueue.main.async {
                self.docController = UIDocumentInteractionController(url: url)
                self.docController?.delegate = self
                self.docController?.presentPreview(animated: true)
            }
        }
    }
    
    private func donate() {
        guard let uid = UserManager.shared.currentUID,
              let donationSum = self.donationSum
        else { return }
        
        let donation = DonationModel(fundraiserId: self.fundraiser.id, fundraiserTitle: self.fundraiser.title,
                                     amount: donationSum, date: Date())
        
        DonateService.shared.updateFundraiserCollectedValue(donation: donation) { result in
            switch result {
            case .success(_):
                self.saveToHistory(uid: uid, donation: donation)
            case .failure(let error):
                self.presentDonateResultViewController(success: false)
            }
        }
    }
    
    private func saveToHistory(uid: String, donation: DonationModel) {
        DonateService.shared.saveDonateToUserHistory(uid: uid, donation: donation) { result in
            switch result {
            case .success:
                self.presentDonateResultViewController(success: true)
            case .failure:
                self.presentDonateResultViewController(success: false)
            }
        }
    }
    
    private func presentDonateResultViewController(success: Bool) {
        let controller = DonateResultViewController(success: success, fundraiserTitle: self.fundraiser.title)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - UIDocumentInteractionControllerDelegate
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        self.docController = nil
        self.donate()
    }
}

