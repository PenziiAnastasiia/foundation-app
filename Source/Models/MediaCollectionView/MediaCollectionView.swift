//
//  InfoView.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 15.04.2025.
//

import UIKit

class MediaCollectionView: UIView {
    
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    
    private var mediaItems: [MediaItem] = []
    private var mediaSizes: [CGSize] = []
    private var dynamicHeightConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nib = UINib(nibName: "MediaCollectionViewCell", bundle: nil)
        self.mediaCollectionView.register(nib, forCellWithReuseIdentifier: "MediaCell")
        
        self.mediaCollectionView.dataSource = self
        self.mediaCollectionView.delegate = self
        
        self.dynamicHeightConstraint = self.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3.0)
        self.dynamicHeightConstraint?.isActive = true
    }
    
    public func loadMedia(for fundraiserID: String, from mediaNamesArray: [String]) {
        let group = DispatchGroup()

        self.mediaItems = mediaNamesArray.map { MediaItem(name: $0, image: nil, size: nil, isVideo: false) }
        self.pullMedia(group: group)
        
        group.notify(queue: .main) {
            self.sizeTransform()
            self.mediaCollectionView.reloadData()
        }
    }
    
    // MARK: - private
    
    private func pullMedia(group: DispatchGroup) {
        for (index, item) in self.mediaItems.enumerated() {
            group.enter()
            
            MediaService.shared.fetchMediaPreview(for: item.name) { result in
                switch result {
                case .success(let (image, isVideo)):
                    self.mediaItems[index].image = image
                    self.mediaItems[index].size = image.size
                    self.mediaItems[index].isVideo = isVideo
                case .failure(let error):
                    print(error)
                }
                group.leave()
            }
        }
    }
    
    private func sizeTransform() {
        let screenWidth = self.mediaCollectionView.frame.width

        let layout = self.mediaCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let sectionInsets = layout?.sectionInset ?? .zero
        let contentInsets = self.mediaCollectionView.contentInset
        
        var totalWidth: CGFloat = 0

        for (index, item) in self.mediaItems.enumerated() {
            guard let size = item.size else { return }
            let aspectRatio = size.width / size.height
            
            let height = self.dynamicHeightConstraint?.constant ?? self.mediaCollectionView.frame.height - sectionInsets.top - sectionInsets.bottom - contentInsets.top - contentInsets.bottom
            let width = height * aspectRatio

            self.mediaItems[index].size = CGSize(width: width, height: height)
            totalWidth += width
        }

        if totalWidth < screenWidth {
            let scaleFactor = screenWidth / totalWidth
            var maxHeight: CGFloat = 0.0

            for (index, item) in self.mediaItems.enumerated() {
                guard let size = item.size else { continue }
                let scaledHeight = size.height * scaleFactor
                let scaledWidth = size.width * scaleFactor

                self.mediaItems[index].size = CGSize(width: scaledWidth, height: scaledHeight)

                maxHeight = max(maxHeight, scaledHeight)
            }
            
            self.dynamicHeightConstraint?.constant = maxHeight
            self.layoutIfNeeded()
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension MediaCollectionView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mediaItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as? MediaCollectionViewCell else {
            return UICollectionViewCell()
        }
        let mediaItem = self.mediaItems[indexPath.item]
        cell.configure(with: mediaItem.image, isVideo: mediaItem.isVideo)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let size = self.mediaItems[indexPath.item].size {
            return CGSize(width: size.width, height: size.height)
        }
        return CGSize(width: 120, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mediaItem = self.mediaItems[indexPath.item]
        var fullscreenVC: UIViewController
        
        if mediaItem.isVideo {
            fullscreenVC = VideoFullscreenViewController()
            if let videoFullscreenVC = fullscreenVC as? VideoFullscreenViewController {
                videoFullscreenVC.videoName = mediaItem.name
            }
        } else {
            fullscreenVC = ImageFullscreenViewController()
            if let imageFullscreenVC = fullscreenVC as? ImageFullscreenViewController {
                imageFullscreenVC.image = mediaItem.image
            }
        }
        fullscreenVC.modalPresentationStyle = .overFullScreen
        
        if let vc = self.parentViewController() {
            vc.present(fullscreenVC, animated: true)
        }
    }
}
