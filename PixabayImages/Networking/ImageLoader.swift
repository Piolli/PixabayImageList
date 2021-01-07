//
//  ImageLoader.swift
//  PixabayImages
//
//  Created by Alexandr Kamyshev on 04.01.2021.
//

import Foundation
import Combine
import Kingfisher
import UIKit

protocol ImageLoader {
    func loadImage(with url: URL, for size: CGSize) -> AnyPublisher<UIImage?, ImageLoaderError>
}

enum ImageLoaderError: Error {
    case storageError(ImageStorageError)
    case loaderError(URLError)
    case unknown(Error)
}


class KingfisherLoader: ImageLoader {
    func loadImage(with url: URL, for size: CGSize) -> AnyPublisher<UIImage?, ImageLoaderError> {
        let processor = DownsamplingImageProcessor(size: size)
        return Future<UIImage?, ImageLoaderError> { (promise) in
            KingfisherManager.shared.retrieveImage(with: url, options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]) { result in
                switch result {
                case .success(let result):
                    promise(.success(result.image))
                case .failure(let error):
                    promise(.failure(.unknown(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
}

class BuiltInImageLoader: ImageLoader {
    
    let imageStorage: ImageStorage
    
    init(imageStorage: ImageStorage) {
        self.imageStorage = imageStorage
    }
    
    func loadImage(with url: URL, for size: CGSize) -> AnyPublisher<UIImage?, ImageLoaderError> {
        return imageStorage.fetch(with: url)
            .catch({  _ in
                URLSession.shared.dataTaskPublisher(for: url)
                    .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                    .map { UIImage(data: $0.data) }
                    .compactMap { $0 }
                    .map {
                        BuiltInImageLoader.downsample(image: $0, to: size)
                    }
                    .handleEvents(receiveOutput: { [weak self] image in
                        guard let image = image, let self = self else {
                            return
                        }
                        print("Image was successfully stored to cache")
                        self.imageStorage.save(image: image, for: url)
                    })
                    .eraseToAnyPublisher()
            })
            .mapError { ImageLoaderError.loaderError($0) }
            .eraseToAnyPublisher()
            
    }
    
    public static func downsample(image: UIImage,
                    to pointSize: CGSize,
                    scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithData(image.pngData()! as CFData, imageSourceOptions)!
        
        // Calculate the desired dimension
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        
        // Perform downsampling
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        print("SOURCE: \(image.size) DOWNSAMPLED: \(downsampledImage.width):\(downsampledImage.height)")
        
        return UIImage(cgImage: downsampledImage)
    }
}
