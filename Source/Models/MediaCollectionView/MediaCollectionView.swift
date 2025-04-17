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
    
    var mediaItems: [MediaItem] = []
    
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
    }
    
    public func loadMedia(for fundraiserID: String, from mediaNamesArray: [String]) {
        let group = DispatchGroup()

        self.mediaItems = mediaNamesArray.map { name in
            let isVideo = name.contains("mp4")
            let urlString = "https://res.cloudinary.com/dofhtvflc/\(isVideo ? "video" : "image")/upload/v1744906116/\(name)"
            return MediaItem(url: URL(string: urlString)!, image: nil, isVideo: isVideo)
        }

        for (index, item) in self.mediaItems.enumerated() {
            group.enter()
            if item.isVideo {
                self.loadVideoPreview(from: item.url) { image in
                    self.mediaItems[index].image = image
                    group.leave()
                }
            } else {
                self.loadImage(from: item.url) { image in
                    self.mediaItems[index].image = image
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.mediaCollectionView.reloadData()
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
        if let size = self.mediaItems[indexPath.item].image?.size {
            let maxHeight: CGFloat = collectionView.bounds.height
            let aspectRatio = size.width / size.height
            let width = maxHeight * aspectRatio
            return CGSize(width: width, height: maxHeight)
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
