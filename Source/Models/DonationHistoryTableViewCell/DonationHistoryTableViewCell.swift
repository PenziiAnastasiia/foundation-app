//
//  DonationHistoryCollectionViewCell.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 29.04.2025.
//

import UIKit

class DonationHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var nestedView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var donateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    public func configure(with donation: DonationModel) {
        self.titleLabel.text = donation.fundraiserTitle
        self.donateLabel.text = "\(donation.donate.formattedWithSeparator()) ₴"
        self.dateLabel.text = DateFormatter.shared.string(from: donation.date)
        
        self.nestedView.layer.cornerRadius = self.nestedView.frame.width / 25
        self.donateLabel.adjustsFontSizeToFitWidth = true
        self.donateLabel.minimumScaleFactor = 0.5
    }
}
