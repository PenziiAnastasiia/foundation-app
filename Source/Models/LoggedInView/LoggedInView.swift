//
//  LoggedInView.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 06.05.2025.
//

import UIKit

class LoggedInView: UIView {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var logout: (() -> Void)?
    
    @IBAction func logoutTapped() {
        self.logout?()
    }
    
    public func configure(_ userImage: UIImage, _ userName: String) {
        self.name.text = userName
    }
}
