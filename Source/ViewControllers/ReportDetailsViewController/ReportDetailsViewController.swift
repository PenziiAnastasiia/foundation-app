//
//  ReportDetailsViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 23.04.2025.
//

import UIKit

class ReportDetailsViewController: UIViewController {
    private var rootView: ReportDetailsView? {
        self.viewIfLoaded as? ReportDetailsView
    }
    
    private let report: ReportModel

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rootView?.fillView(with: self.report)
        self.rootView?.fillMediaCollectionView(for: self.report)
    }
    
    init(report: ReportModel) {
        self.report = report
        super.init(nibName: "ReportDetailsViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
