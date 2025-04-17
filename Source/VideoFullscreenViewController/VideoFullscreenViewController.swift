//
//  VideoFullscreenViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 17.04.2025.
//

import UIKit
import AVKit

class VideoFullscreenViewController: UIViewController {
    var videoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        if let videoURL = videoURL {
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            
            self.addChild(playerViewController)
            self.view.addSubview(playerViewController.view)
            playerViewController.view.frame = view.bounds
            playerViewController.didMove(toParent: self)
            
            player.play()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreen))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissFullscreen() {
        dismiss(animated: true)
    }
}
