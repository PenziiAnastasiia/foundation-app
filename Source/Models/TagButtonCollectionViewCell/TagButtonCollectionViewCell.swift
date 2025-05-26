//
//  TagButtonCollectionViewCell.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 25.05.2025.
//

import UIKit

class TagButtonCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var BGView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.BGView.translatesAutoresizingMaskIntoConstraints = false
        self.BGView.setCornerRadius()
    }
    
    override var isSelected: Bool {
        didSet {
            self.BGView.backgroundColor = isSelected ? UIColor.systemBlue.withAlphaComponent(0.2) : .container
        }
    }
    
    public func configureWithTitle(_ title: String) {
        self.titleLabel.text = title
        self.titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
