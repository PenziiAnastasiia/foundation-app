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
    @IBOutlet var goalLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    private var listElement: ListElementModel?
    private var action: ((Int) -> Void)?
    private var progressValue: Float = 0.0 {
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

        self.progressBarView.frame = CGRect(x: 0, y: 0, width: 0, height: self.barView.frame.height)
        let cornerRadius = self.barView.bounds.height / 5
        self.barView.layer.cornerRadius = cornerRadius
        self.progressBarView.layer.cornerRadius = cornerRadius
    }
    
    @IBAction func didElementTapped(sender: UIButton) {
        self.action?(self.listElement?.id ?? 0)
    }
    
    public func fillView(with listElement: ListElementModel, action: @escaping (Int) -> Void) {
        self.listElement = listElement
        self.action = action
        
        self.titleLabel.text = listElement.title
        self.progressValue = listElement.amount / listElement.goal
        self.amountLabel.text = "\(listElement.amount)"
        self.goalLabel.text = "\(Int(listElement.goal))"
        
        if case let .closed(closeDate) = listElement.status {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            self.dateLabel.text = dateFormatter.string(from: closeDate)
        }
    }
    
    private func updateProgressLayer() {
        let barWidth = CGFloat(self.progressValue) * self.barView.bounds.width
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.progressBarView.frame.size.width = barWidth
        }
    }
}
