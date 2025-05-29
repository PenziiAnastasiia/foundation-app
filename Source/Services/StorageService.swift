//
//  MediaService.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 20.05.2025.
//

import FirebaseStorage
import AVFoundation
import UIKit

final class StorageService {
    
    static let shared = StorageService()
    
    private init() {}
    
    func fetchMediaPreview(for filename: String, completion: @escaping (Result<(UIImage, Bool), Error>) -> Void) {
        let lowercasedName = filename.lowercased()
        
        if lowercasedName.hasSuffix(".jpg") || lowercasedName.hasSuffix(".jpeg") || lowercasedName.hasSuffix(".png") || lowercasedName.hasSuffix(".webp") {
            self.fetchImage(from: filename, completion: completion)
        } else if lowercasedName.hasSuffix(".mp4") {
            self.fetchVideoPreview(from: filename, completion: completion)
        }
    }
    
    func getMediaURL(from path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        Storage.storage().reference(withPath: path).downloadURL { url, error in
            if let url = url {
                completion(.success(url))
            } else if let error = error {
                completion(.failure(error))
            }
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
        self.getMediaURL(from: path) { result in
            switch result {
            case .success(let url):
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
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
