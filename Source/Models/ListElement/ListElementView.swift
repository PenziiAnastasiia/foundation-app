//
//  ListElementModel.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 04.01.2025.
//

import Foundation
import UIKit

class ListElementView: UIView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var barView: UIView!
    @IBOutlet var progressBarView: UIView!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var markersView: UIView!
    @IBOutlet var goalLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var collectedLabel: UILabel!
    
    private var fundraiser: FundraiserModel?
    private var action: (() -> Void)?
    private var progressValue: Double = 0.0 {
        didSet {
            updateProgressLayer()
        }
    }
    
    class func loadFromNib() -> ListElementView? {
        let nib = UINib(nibName: "ListElementView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil).first as? ListElementView
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.progressBarView.frame = CGRect(x: 0, y: 0, width: 0, height: self.barView.bounds.height)
        let cornerRadius = self.barView.bounds.height / 5
        self.barView.layer.cornerRadius = cornerRadius
        self.progressBarView.layer.cornerRadius = cornerRadius
    }
    
    @IBAction func didElementTapped(sender: UIButton) {
        self.action?()
    }
    
    public func fillView(with fundraiser: FundraiserModel, action: @escaping () -> Void) {
        self.fundraiser = fundraiser
        self.action = action
        
        self.titleLabel.text = fundraiser.title
        
        if let closeDate = fundraiser.closeDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            self.dateLabel.text = dateFormatter.string(from: closeDate)
            
            self.collectedLabel.text = "Зібрано: \(self.formatNumber(fundraiser.collected))"
        } else {
            self.barView.isHidden = false
            self.markersView.isHidden = false
            self.progressValue = fundraiser.collected / Double(fundraiser.goal)
            self.goalLabel.text = self.formatNumber(fundraiser.goal)
            self.amountLabel.text = self.formatNumber(fundraiser.collected)
        }
    }
    
    private func formatNumber<T: Numeric>(_ number: T) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        
        if let doubleValue = number as? Double {
            return formatter.string(from: NSNumber(value: doubleValue)) ?? "\(number)"
        } else if let intValue = number as? Int {
            return formatter.string(from: NSNumber(value: intValue)) ?? "\(number)"
        } else {
            return "\(number)"
        }
    }
    
    private func updateProgressLayer() {
        let barWidth = CGFloat(self.progressValue) * self.barView.bounds.width
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.progressBarView.frame.size.width = barWidth
        }
    }
}
