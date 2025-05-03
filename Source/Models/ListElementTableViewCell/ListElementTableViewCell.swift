//
//  ListElementModel.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 04.01.2025.
//

import Foundation
import UIKit

class ListElementTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nestedView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var labelsContainer: UIView!
    @IBOutlet weak var barViewContainer: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectedLabel: UILabel!
    
    private var barView: BarView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleLabel.text = ""
        self.dateLabel.text = ""
        self.collectedLabel.text = ""
        self.labelsContainer.isHidden = true
        self.barViewContainer.isHidden = true
        self.barView?.collectedLabel.text = ""
        self.barView?.goalLabel.text = ""
        self.barView = nil
    }
    
    public func configure(with fundraiser: FundraiserModel) {
        self.titleLabel.text = fundraiser.title
        
        if let closeDate = fundraiser.closeDate {
            self.fillWithoutBarView(closeDate: closeDate, collected: fundraiser.collected)
        } else {
            self.fillWithBarView(collected: fundraiser.collected, goal: fundraiser.goal)
        }
        
        self.nestedView.layer.cornerRadius = self.nestedView.frame.width / 25
    }
    
    public func configure(with report: ReportModel) {
        self.titleLabel.text = report.title
        self.fillWithoutBarView(closeDate: report.closeDate, collected: report.collected)
        self.nestedView.layer.cornerRadius = self.nestedView.frame.width / 25
    }
    
    private func fillWithoutBarView(closeDate: Date, collected: Double) {
        self.labelsContainer.isHidden = false
        self.dateLabel.text = DateFormatter.shared.string(from: closeDate)
        self.collectedLabel.text = "Зібрано: \(collected.formattedWithSeparator())"
    }
    
    private func fillWithBarView(collected: Double, goal: Int) {
        self.addBarView(collected: collected, goal: goal)
        self.barViewContainer.isHidden = false
    }
    
    private func addBarView(collected: Double, goal: Int) {
        self.barViewContainer.subviews.forEach { $0.removeFromSuperview() }

        if let barView = BarView.loadFromNib() {
            barView.translatesAutoresizingMaskIntoConstraints = false
            self.barViewContainer.addSubview(barView)
            NSLayoutConstraint.activate([
                barView.leadingAnchor.constraint(equalTo: self.barViewContainer.leadingAnchor),
                barView.trailingAnchor.constraint(equalTo: self.barViewContainer.trailingAnchor),
                barView.topAnchor.constraint(equalTo: self.barViewContainer.topAnchor),
                barView.bottomAnchor.constraint(equalTo: self.barViewContainer.bottomAnchor)
            ])
            barView.progressBackgroundView.layer.cornerRadius = barView.progressBackgroundView.frame.height / 4
            barView.progressView.layer.cornerRadius = barView.progressView.frame.height / 4
            self.barViewContainer.layoutIfNeeded()
            barView.setProgress(collected: collected, goal: goal)
            self.barView = barView
        }
    }
}
