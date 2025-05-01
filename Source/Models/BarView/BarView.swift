//
//  BarView.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 13.04.2025.
//

import UIKit

class BarView: UIView {
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressBackgroundView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var collectedLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    
    class func loadFromNib() -> BarView? {
        let nib = UINib(nibName: "BarView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil).first as? BarView
    }
    
    public func setProgress(collected: Double, goal: Int) {
        let progress = max(collected / Double(goal), 0.0)
        let barWidth = max(CGFloat(min(progress, 1.0)) * self.progressBackgroundView.frame.width, 1.0)
        
        self.progressWidthConstraint.constant = barWidth
        
        collectedLabel.text = "\(collected.formattedWithSeparator())₴, \(round((progress * 100) * 100) / 100)%"
        goalLabel.text = "\(goal.formattedWithSeparator())"
    }
}
