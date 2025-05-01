//
//  InfoView.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 15.04.2025.
//

import UIKit
import Kingfisher
import AVFoundation

class MediaCollectionView: UIView {
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    
    private var mediaItems: [MediaItem] = []
    private var mediaSizes: [CGSize] = []
    private var dynamicHeightConstraint: NSLayoutConstraint?
    
    class func loadFromNib() -> MediaCollectionView? {
        let nib = UINib(nibName: "MediaCollectionView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil).first as? MediaCollectionView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nib = UINib(nibName: "MediaCollectionViewCell", bundle: nil)
        self.mediaCollectionView.register(nib, forCellWithReuseIdentifier: "MediaCell")
        
        self.mediaCollectionView.dataSource = self
        self.mediaCollectionView.delegate = self
        
        self.dynamicHeightConstraint = self.heightAnchor.constraint(greaterThanOrEqualToConstant: UIScreen.main.bounds.height / 3.0)
        self.dynamicHeightConstraint?.isActive = true
    }
    
    public func loadMedia(for fundraiserID: String, from mediaNamesArray: [String]) {
        let group = DispatchGroup()

        self.createMediaItemsModels(from: mediaNamesArray)
        self.pullMedia(group: group)
        
        group.notify(queue: .main) {
            self.sizeTransform()
            self.mediaCollectionView.reloadData()
        }
    }
    
    private func createMediaItemsModels(from mediaNamesArray: [String]) {
        self.mediaItems = mediaNamesArray.map { name in
            let isVideo = name.contains("mp4")
            let urlString = "https://res.cloudinary.com/dofhtvflc/\(isVideo ? "video" : "image")/upload/v1744906116/\(name)"
            return MediaItem(url: URL(string: urlString)!, image: nil, isVideo: isVideo, size: nil)
        }
    }
    
    private func pullMedia(group: DispatchGroup) {
        for (index, item) in self.mediaItems.enumerated() {
            group.enter()
            if item.isVideo {
                self.loadVideoPreview(from: item.url) { image in
                    self.handleLoadedImage(image, for: index, group: group)
                }
            } else {
                self.loadImage(from: item.url) { image in
                    self.handleLoadedImage(image, for: index, group: group)
                }
            }
        }
    }

    private func loadVideoPreview(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: url)
        asset.loadTracks(withMediaType: .video) { tracks, error in
            if let error = error {
                print("Failed to load tracks: \(error)")
                completion(nil)
                return
            }

            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 1, preferredTimescale: 600)
            do {
                let imageRef = try generator.copyCGImage(at: time, actualTime: nil)
                let previewImage = UIImage(cgImage: imageRef)
                completion(previewImage)
            } catch {
                print("Failed to generate preview: \(error)")
                completion(nil)
            }
        }
    }

    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            if let value = try? result.get() {
                DispatchQueue.main.async {
                    completion(value.image)
                }
            } else {
                print("Failed to load image")
                completion(nil)
            }
        }
    }
    
    private func handleLoadedImage(_ image: UIImage?, for index: Int, group: DispatchGroup) {
        self.mediaItems[index].image = image
        self.mediaItems[index].size = image?.size
        group.leave()
    }
    
    private func sizeTransform() {
        let screenWidth = self.mediaCollectionView.frame.width
        var totalWidth: CGFloat = 0

        for (index, item) in self.mediaItems.enumerated() {
            guard let size = item.size else { return }
            let aspectRatio = size.width / size.height
            let height = self.mediaCollectionView.frame.height
            let width = height * aspectRatio
            
            self.mediaItems[index].size = CGSizeMake(width, height)
            totalWidth += width
        }

        if totalWidth < screenWidth {
            let scaleFactor = screenWidth / totalWidth
            var maxHeight = self.dynamicHeightConstraint?.constant ?? 0.0
            
            for (index, item) in self.mediaItems.enumerated() {
                guard let size = item.size else { return }
                let height = size.height * scaleFactor
                self.mediaItems[index].size = CGSizeMake(size.width * scaleFactor, height)
                
                if height > maxHeight {
                    maxHeight = height
                }
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
                videoFullscreenVC.videoURL = mediaItem.url
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
