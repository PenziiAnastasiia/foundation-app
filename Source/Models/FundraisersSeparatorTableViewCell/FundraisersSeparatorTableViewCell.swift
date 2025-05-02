//
//  FundraisersSeparatorTableViewCell.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 01.05.2025.
//

import UIKit

class FundraisersSeparatorTableViewCell: UITableViewCell {
    
    @IBOutlet var separatorLabel: UILabel!
    @IBOutlet var topConstraint: NSLayoutConstraint!

    override func prepareForReuse() {
        self.separatorLabel.text = ""
    }
    
    public func configure(with title: String, _ editConstraint: Bool) {
        self.separatorLabel.text = title
        
        self.topConstraint.constant = editConstraint ? 48 : 0
    }
    
}
