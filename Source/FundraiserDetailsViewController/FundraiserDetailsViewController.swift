//
//  FundraiserDetailsViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 06.01.2025.
//

import UIKit

class FundraiserDetailsViewController: UIViewController {
    private var rootView: FundraiserDetailsView? {
        self.viewIfLoaded as? FundraiserDetailsView
    }
    
    let fundraiser: FundraiserListElement

    override func viewDidLoad() {
        super.viewDidLoad()

        self.rootView?.configure(title: self.fundraiser.title)
    }
    
    init(fundraiser: FundraiserListElement) {
        self.fundraiser = fundraiser
        super.init(nibName: "FundraiserDetailsViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
