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
        self.descriptionLabel.text = ""
    }
    
    public func fillMediaCollectionView(for report: ReportModel) {
        guard let namesArray = report.reportMediaNames
        else {
            self.mediaCollectionContainer.isHidden = true
            return
        }
        
        if let mediaCollectionView = MediaCollectionView.loadFromNib() {
            mediaCollectionView.translatesAutoresizingMaskIntoConstraints = false
            self.mediaCollectionContainer.addSubview(mediaCollectionView)
            NSLayoutConstraint.activate([
                mediaCollectionView.leadingAnchor.constraint(equalTo: self.mediaCollectionContainer.leadingAnchor, constant: 16),
                mediaCollectionView.trailingAnchor.constraint(equalTo: self.mediaCollectionContainer.trailingAnchor, constant: -16),
                mediaCollectionView.topAnchor.constraint(equalTo: self.mediaCollectionContainer.topAnchor, constant: 16),
                mediaCollectionView.bottomAnchor.constraint(equalTo: self.mediaCollectionContainer.bottomAnchor, constant: -16)
            ])
            self.mediaCollectionContainer.layer.cornerRadius = self.mediaCollectionContainer.bounds.width / 20
            mediaCollectionView.loadMedia(for: report.id, from: namesArray)
            self.activityIndicatorView.stopAnimating()
        }
    }
}

