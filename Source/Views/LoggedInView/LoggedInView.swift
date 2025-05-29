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
    @IBOutlet weak var settingsButton: UIButton!
    
    var changeData: (() -> Void)?
    var logout: (() -> Void)?
    
    public func configure(_ userEmoji: String, _ userName: String) {
        self.name.text = userName
        self.emoji.text = userEmoji
        self.emojiContainer.layer.cornerRadius = self.emojiContainer.frame.width / 2
        self.emojiContainer.layer.masksToBounds = true
        
        let action1 = UIAction(title: "Змінити особисту інформацію", image: nil) { _ in
            self.changeData?()
        }
        
        let action2 = UIAction(title: "Вийти з акаунту", image: nil) { _ in
            self.logout?()
        }

        let menu = UIMenu(title: "", children: [action1, action2])
        self.settingsButton.menu = menu
        self.settingsButton.showsMenuAsPrimaryAction = true
    }
}
