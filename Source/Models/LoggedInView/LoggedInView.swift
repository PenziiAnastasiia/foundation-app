//
//  LoggedInView.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 06.05.2025.
//

import UIKit

class LoggedInView: UIView {
    
    @IBOutlet weak var emojiContainer: UIView!
    @IBOutlet weak var emoji: UILabel!
    @IBOutlet weak var name: UILabel!
    
    var logout: (() -> Void)?
    
    @IBAction func logoutTapped() {
        self.logout?()
    }
    
    public func configure(_ userEmoji: String, _ userName: String) {
        self.name.text = userName
        self.emoji.text = userEmoji
        self.emojiContainer.layer.cornerRadius = self.emojiContainer.frame.width / 2
        self.emojiContainer.layer.masksToBounds = true
    }
}
