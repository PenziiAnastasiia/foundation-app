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
    private let closeButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        self.configureScrollView()
        self.configureImageView()
        self.configureCloseButton()
        
        self.imageView.image = self.image
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    private func configureScrollView() {
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 4.0
        self.scrollView.frame = self.view.frame
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.scrollView)
    }
    
    private func configureImageView() {
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.frame = self.scrollView.frame
        self.imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollView.addSubview(self.imageView)
    }
    
    private func configureCloseButton() {
        self.closeButton.setTitle("✕", for: .normal)
        self.closeButton.setTitleColor(.white, for: .normal)
        self.closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .regular)
        self.closeButton.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.closeButton.layer.cornerRadius = 20
        self.closeButton.clipsToBounds = true
        self.closeButton.addTarget(self, action: #selector(self.dismissFullscreen), for: .touchUpInside)
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.closeButton)
        
        NSLayoutConstraint.activate([
            self.closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            self.closeButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.closeButton.widthAnchor.constraint(equalToConstant: 40),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func dismissFullscreen() {
        dismiss(animated: true)
    }
}

