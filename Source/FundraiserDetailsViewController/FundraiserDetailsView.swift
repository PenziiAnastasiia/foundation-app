//
//  FundraiserDetailsView.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 06.01.2025.
//

import UIKit

class FundraiserDetailsView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mediaCollectionContainer: UIView!
    
    public func fillView(with fundraiser: FundraiserModel, mediaNamesArray: [String]) {
        self.titleLabel.text = fundraiser.title
        self.descriptionLabel.text = fundraiser.description
        self.fillMediaCollectionView(for: fundraiser.id, with: mediaNamesArray)
    }
    
    private func fillMediaCollectionView(for fundraiserID: String, with namesArray: [String]) {
        if namesArray.isEmpty {
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
            mediaCollectionView.loadMedia(for: fundraiserID, from: namesArray)
        }
    }
}
