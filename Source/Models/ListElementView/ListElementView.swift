//
//  ListElementModel.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 04.01.2025.
//

import Foundation
import UIKit

class ListElementView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var labelsContainer: UIView!
    @IBOutlet weak var barViewContainer: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectedLabel: UILabel!

    private var action: (() -> Void)?
    private var barView: BarView?
    
    class func loadFromNib() -> ListElementView? {
        let nib = UINib(nibName: "ListElementView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil).first as? ListElementView
    }
    
    @IBAction func didElementTapped(sender: UIButton) {
        self.action?()
    }
    
    public func addBarView() {
        if let barView = BarView.loadFromNib() {
            barView.translatesAutoresizingMaskIntoConstraints = false
            self.barViewContainer.addSubview(barView)
            NSLayoutConstraint.activate([
                barView.leadingAnchor.constraint(equalTo: self.barViewContainer.leadingAnchor),
                barView.trailingAnchor.constraint(equalTo: self.barViewContainer.trailingAnchor),
                barView.topAnchor.constraint(equalTo: self.barViewContainer.topAnchor),
                barView.bottomAnchor.constraint(equalTo: self.barViewContainer.bottomAnchor)
            ])
            barView.progressBackgroundView.layer.cornerRadius = barView.progressBackgroundView.bounds.height / 4
            barView.progressView.layer.cornerRadius = barView.progressView.bounds.height / 4
            self.barView = barView
            self.barViewContainer.layoutIfNeeded()
        }
    }
    
    public func fillView(with fundraiser: FundraiserModel, action: @escaping () -> Void) {
        self.action = action
        
        self.titleLabel.text = fundraiser.title
        
        if let closeDate = fundraiser.closeDate {
            self.labelsContainer.isHidden = false
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            self.dateLabel.text = dateFormatter.string(from: closeDate)
            
            self.collectedLabel.text = "Зібрано: \(fundraiser.collected.formattedWithSeparator())"
        } else {
            self.barViewContainer.isHidden = false
            self.barView?.setProgress(collected: fundraiser.collected, goal: fundraiser.goal)
        }
    }
}
