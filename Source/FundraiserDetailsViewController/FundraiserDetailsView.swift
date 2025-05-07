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
    
    public func fillView(with fundraiser: FundraiserModel, donateFunc: @escaping (Double, Int?, Date?, Int?) -> Void) {
        self.titleLabel.text = fundraiser.title
        self.descriptionLabel.text = fundraiser.description
        self.addBarView(collected: fundraiser.collected, goal: fundraiser.goal)
        if fundraiser.closeDate == nil {
            self.donateViewContainer.superview?.isHidden = false
            self.addDonateView(fundraiserID: fundraiser.id, donateFunc: donateFunc)
        }
    }
    
    public func fillMediaCollectionView(for fundraiser: FundraiserModel) {
        guard let namesArray = fundraiser.descriptionMediaNames
        else {
            self.mediaCollectionContainer.superview?.isHidden = true
            return
        }
        
        if let mediaCollectionView = MediaCollectionView.loadFromNib() {
            mediaCollectionView.embedIn(self.mediaCollectionContainer)
            self.mediaCollectionContainer.superview?.layer.cornerRadius = self.mediaCollectionContainer.frame.width / 20
            mediaCollectionView.loadMedia(for: fundraiser.id, from: namesArray)
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    private func addBarView(collected: Double, goal: Int) {
        if let barView = BarView.loadFromNib() {
            barView.embedIn(self.barViewContainer)
            barView.progressBackgroundView.layer.cornerRadius = barView.progressBackgroundView.frame.height / 4
            barView.progressView.layer.cornerRadius = barView.progressView.frame.height / 4
            self.barViewContainer.superview?.layer.cornerRadius = self.barViewContainer.frame.width / 20
            self.barViewContainer.superview?.layoutIfNeeded()
            barView.layoutIfNeeded()
            DispatchQueue.main.async {
                barView.setProgress(collected: collected, goal: goal)
            }
        }
    }
    
    private func addDonateView(fundraiserID: String, donateFunc: @escaping (Double, Int?, Date?, Int?) -> Void) {
        if let donateView = DonateView.loadFromNib() {
            donateView.embedIn(self.donateViewContainer)
            self.donateViewContainer.superview?.layoutIfNeeded()
            self.donateViewContainer.superview?.layer.cornerRadius = self.donateViewContainer.frame.width / 20
            donateView.configure(donate: { sum, cardNumber, expiredIn, CVV2 in
                donateFunc(sum, cardNumber, expiredIn, CVV2)
            })
        }
    }
}
