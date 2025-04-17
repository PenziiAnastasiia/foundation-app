//
//  MediaFullscreenViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 16.04.2025.
//

import UIKit

class ImageFullscreenViewController: UIViewController, UIScrollViewDelegate {
    var image: UIImage?
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(scrollView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.frame = scrollView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(imageView)
        
        imageView.image = self.image

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreen))
        view.addGestureRecognizer(tapGesture)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    @objc private func dismissFullscreen() {
        dismiss(animated: true)
    }
}

