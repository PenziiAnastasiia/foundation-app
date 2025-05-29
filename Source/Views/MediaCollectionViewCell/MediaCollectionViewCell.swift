//
//  MediaCollectionViewCell.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 15.04.2025.
//

import UIKit

class MediaCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    public func configure(with image: UIImage?, isVideo: Bool) {
        self.imageView.image = image
        self.playImageView.isHidden = !isVideo
        self.imageView.setCornerRadius(value: 8)
    }
}
