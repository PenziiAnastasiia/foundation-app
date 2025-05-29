//
//  ReportDetailsView.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 23.04.2025.
//

import UIKit

class ReportDetailsView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mediaCollectionContainer: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    public func fillView(with report: ReportModel) {
        self.titleLabel.text = report.title
        self.descriptionLabel.text = report.description
    }
    
    public func fillMediaCollectionView(for report: ReportModel) {
        guard let namesArray = report.reportMedia
        else {
            self.mediaCollectionContainer.superview?.isHidden = true
            return
        }
        
        if let mediaCollectionView = MediaCollectionView.loadFromNib() {
            mediaCollectionView.embedIn(self.mediaCollectionContainer)
            self.mediaCollectionContainer.superview?.setCornerRadius()
            mediaCollectionView.loadMedia(for: report.id, from: namesArray)
            self.activityIndicatorView.stopAnimating()
        }
    }
}
