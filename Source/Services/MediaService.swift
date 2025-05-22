//
//  MediaService.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 20.05.2025.
//

import FirebaseStorage
import AVFoundation
import UIKit

final class MediaService {
    
    static let shared = MediaService()
    
    private init() {}
    
    func fetchMediaPreview(for filename: String, completion: @escaping (Result<(UIImage, Bool), Error>) -> Void) {
        let lowercasedName = filename.lowercased()
        var path: String
        
        if lowercasedName.hasSuffix(".jpg") || lowercasedName.hasSuffix(".jpeg") || lowercasedName.hasSuffix(".png") || lowercasedName.hasSuffix(".webp") {
            self.fetchImage(from: filename, completion: completion)
        } else if lowercasedName.hasSuffix(".mp4") {
            self.fetchVideoPreview(from: filename, completion: completion)
        }
    }
    
    private func fetchImage(from path: String, completion: @escaping (Result<(UIImage, Bool), Error>) -> Void) {
        let storageRef = Storage.storage().reference(withPath: path)
        
        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let image = UIImage(data: data) {
                completion(.success((image, false)))
            } else {
                let error = NSError(domain: "MediaService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Щось пішло не так"])
                completion(.failure(error))
            }
        }
    }
    
    private func fetchVideoPreview(from path: String, completion: @escaping (Result<(UIImage, Bool), Error>) -> Void) {
        let storageRef = Storage.storage().reference(withPath: path)
        storageRef.downloadURL { url, error in
            if let error = error {
                completion(.failure(error))
            } else if let url = url {
                let asset = AVAsset(url: url)
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                let time = CMTime(seconds: 1, preferredTimescale: 600)
                
                do {
                    let imageRef = try generator.copyCGImage(at: time, actualTime: nil)
                    let previewImage = UIImage(cgImage: imageRef)
                    completion(.success((previewImage, true)))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
