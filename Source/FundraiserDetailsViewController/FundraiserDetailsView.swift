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
    
    private var donateView: DonateView?
    
    public func fillView(with fundraiser: FundraiserModel) {
        self.titleLabel.text = fundraiser.title
        self.descriptionLabel.text = fundraiser.description
        self.addBarView(collected: fundraiser.collected, goal: fundraiser.goal)
        self.donateViewContainer.superview?.setCornerRadius()
        
        if fundraiser.closeDate == nil {
            self.donateViewContainer.superview?.isHidden = false
        }
    }
    
    public func fillMediaCollectionView(for fundraiser: FundraiserModel) {
        guard let namesArray = fundraiser.descriptionMedia
        else {
            self.mediaCollectionContainer.superview?.isHidden = true
            return
        }
        
        if let mediaCollectionView = MediaCollectionView.loadFromNib() {
            mediaCollectionView.embedIn(self.mediaCollectionContainer)
            self.mediaCollectionContainer.superview?.setCornerRadius()
            mediaCollectionView.loadMedia(for: fundraiser.id, from: namesArray)
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    public func fillDonateView(with applePayButton: UIButton? = nil, generateInvoiceFunc: ((Double) -> Void)? = nil) {
        if let donateView = DonateView.loadFromNib() {
            donateView.embedIn(self.donateViewContainer)
            self.donateViewContainer.superview?.layoutIfNeeded()
            donateView.configure(with: applePayButton, generateInvoice: generateInvoiceFunc)
            self.donateView = donateView
        }
    }
    
    public func getDonationSum() -> Double? {
        return self.donateView?.getDonationSum()
    }
    
    // MARK: - private
    
    private func addBarView(collected: Double, goal: Int) {
        if let barView = BarView.loadFromNib() {
            barView.embedIn(self.barViewContainer)
            barView.progressBackgroundView.setCornerRadius(value: 10)
            barView.progressView.setCornerRadius(value: 10)
            self.barViewContainer.superview?.setCornerRadius()
            self.barViewContainer.superview?.layoutIfNeeded()
            barView.layoutIfNeeded()
            DispatchQueue.main.async {
                barView.setProgress(collected: collected, goal: goal)
            }
        }
    }
}
