//
//  VideoFullscreenViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 17.04.2025.
//

import UIKit
import AVKit
import FirebaseStorage

class VideoFullscreenViewController: UIViewController {
    var videoName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)
        
        if let videoName = videoName {
            Storage.storage().reference(withPath: videoName).downloadURL { url, error in
                if let url = url {
                    let player = AVPlayer(url: url)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    
                    self.addChild(playerViewController)
                    self.view.addSubview(playerViewController.view)
                    playerViewController.view.frame = self.view.bounds
                    playerViewController.didMove(toParent: self)
                    
                    player.play()
                } else if let error = error {
                    print(error)
                    self.dismiss(animated: true)
                }
            }
        }
    }
}
