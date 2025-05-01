//
//  FundraiserDetailsView.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 06.01.2025.
//

import UIKit

class FundraiserDetailsView: UIView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mediaCollectionContainer: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var barViewContainer: UIView!
    @IBOutlet weak var donateViewContainer: UIView!
    
    public func fillView(with fundraiser: FundraiserModel) {
        self.titleLabel.text = fundraiser.title
        self.descriptionLabel.text = fundraiser.description
        self.addBarView(collected: fundraiser.collected, goal: fundraiser.goal)
        if fundraiser.closeDate == nil {
            self.donateViewContainer.isHidden = false
            self.addDonateView()
        }
    }
    
    public func fillMediaCollectionView(for fundraiser: FundraiserModel) {
        guard let namesArray = fundraiser.descriptionMediaNames
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
            self.mediaCollectionContainer.layer.cornerRadius = self.mediaCollectionContainer.frame.width / 20
            mediaCollectionView.loadMedia(for: fundraiser.id, from: namesArray)
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    private func addBarView(collected: Double, goal: Int) {
        if let barView = BarView.loadFromNib() {
            barView.translatesAutoresizingMaskIntoConstraints = false
            self.barViewContainer.addSubview(barView)
            NSLayoutConstraint.activate([
                barView.leadingAnchor.constraint(equalTo: self.barViewContainer.leadingAnchor, constant: 16),
                barView.trailingAnchor.constraint(equalTo: self.barViewContainer.trailingAnchor, constant: -16),
                barView.topAnchor.constraint(equalTo: self.barViewContainer.topAnchor, constant: 16),
                barView.bottomAnchor.constraint(equalTo: self.barViewContainer.bottomAnchor)
            ])
            barView.progressBackgroundView.layer.cornerRadius = barView.progressBackgroundView.frame.height / 4
            barView.progressView.layer.cornerRadius = barView.progressView.frame.height / 4
            self.barViewContainer.layer.cornerRadius = self.barViewContainer.frame.width / 20
            self.barViewContainer.layoutIfNeeded()
            barView.layoutIfNeeded()
            DispatchQueue.main.async {
                barView.setProgress(collected: collected, goal: goal)
            }
        }
    }
    
    private func addDonateView() {
        if let donateView = DonateView.loadFromNib() {
            donateView.translatesAutoresizingMaskIntoConstraints = false
            self.donateViewContainer.addSubview(donateView)
            NSLayoutConstraint.activate([
                donateView.leadingAnchor.constraint(equalTo: self.donateViewContainer.leadingAnchor, constant: 16),
                donateView.trailingAnchor.constraint(equalTo: self.donateViewContainer.trailingAnchor, constant: -16),
                donateView.topAnchor.constraint(equalTo: self.donateViewContainer.topAnchor, constant: 16),
                donateView.bottomAnchor.constraint(equalTo: self.donateViewContainer.bottomAnchor, constant: -16)
            ])
            self.donateViewContainer.layoutIfNeeded()
            self.donateViewContainer.layer.cornerRadius = self.donateViewContainer.frame.width / 20
            donateView.configure()
        }
    }
}
