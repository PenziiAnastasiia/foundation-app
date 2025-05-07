//
//  DonateResultViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 03.05.2025.
//

import UIKit
import ImageIO

class DonateResultViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    private var success: Bool
    private var fundraiserTitle: String

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.success {
            self.fillAsSuccess()
        } else {
            self.fillAsFailure()
        }
    }
    
    init(success: Bool, fundraiserTitle: String) {
        self.success = success
        self.fundraiserTitle = fundraiserTitle
        super.init(nibName: "DonateResultViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fillAsSuccess() {
        self.titleLabel.text = self.fundraiserTitle
        self.topLabel.text = "Донат на збір успішно виконано!"
        self.bottomLabel.text = "Дякуємо!"
        
        self.imageView.image = animatedImageWithGIF(named: "success")
    }
    
    private func fillAsFailure() {
        self.topLabel.text = "Виникла помилка"
        self.bottomLabel.text = "Повторіть спробу ще раз"
        
        self.imageView.image = animatedImageWithGIF(named: "failure")
    }

    private func animatedImageWithGIF(named name: String) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif"),
              let data = try? Data(contentsOf: url),
              let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        var images = [UIImage]()
        var totalDuration: Double = 0

        let count = CGImageSourceGetCount(source)
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))

                let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as Dictionary?
                let gifProperties = (properties?[kCGImagePropertyGIFDictionary] as? NSDictionary)
                let delayTime = gifProperties?[kCGImagePropertyGIFUnclampedDelayTime] as? NSNumber ??
                                gifProperties?[kCGImagePropertyGIFDelayTime] as? NSNumber ?? 0
                totalDuration += delayTime.doubleValue
            }
        }

        return UIImage.animatedImage(with: images, duration: totalDuration)
    }
}
