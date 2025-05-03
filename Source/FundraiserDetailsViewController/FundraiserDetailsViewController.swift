//
//  FundraiserDetailsViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 06.01.2025.
//

import UIKit
import FirebaseFirestore

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
        
        self.rootView?.fillView(with: self.fundraiser, donateFunc: { sum in
            DonateService.shared.updateFundraiserCollectedValue(fundraiserID: self.fundraiser.id, donationAmount: sum) { result in
                switch result {
                case .success:
                    print("Донат успішно додано")
                case .failure(let error):
                    print("Помилка при оновленні збору: \(error.localizedDescription)")
                }
            }
        })
        self.rootView?.fillMediaCollectionView(for: self.fundraiser)
        self.startObservingKeyboard()
    }
    
    init(fundraiser: FundraiserModel) {
        self.fundraiser = fundraiser
        super.init(nibName: "FundraiserDetailsViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.enableHideKeyboardOnTap()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopObservingKeyboard()
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
