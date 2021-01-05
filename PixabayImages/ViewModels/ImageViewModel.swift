//
//  ImageViewModel.swift
//  PixabayImages
//
//  Created by Alexandr Kamyshev on 27.12.2020.
//

import Foundation
import Combine
import UIKit

class ImageViewModel {
    private let imageEntity: ImageEntity
    private let imageLoader: ImageLoader
    
    var likeText: String {
        return "❤️ \(imageEntity.likes)"
    }
    
    var downloadsText: String {
        return "\(imageEntity.downloads) ⬇️"
    }
    
    var imageSize: CGSize {
        return .init(width: imageEntity.imageWidth, height: imageEntity.imageHeight)
    }
    
    var aspectRatio: CGFloat {
        return imageSize.height / imageSize.width
    }
    
    var imageURL: URL? {
        return URL(string: imageEntity.largeImageURL)
    }
    
    init(imageEntity: ImageEntity, imageLoader: ImageLoader) {
        self.imageEntity = imageEntity
        self.imageLoader = imageLoader
    }
    
    func fetchImage() -> AnyPublisher<UIImage?, ImageLoaderError> {
        guard let url = imageURL else {
            return Combine.Empty().eraseToAnyPublisher()
        }
        return imageLoader.loadImage(with: url)
            .eraseToAnyPublisher()
    }
    
    
}
