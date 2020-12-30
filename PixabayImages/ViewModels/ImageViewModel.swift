//
//  ImageViewModel.swift
//  PixabayImages
//
//  Created by Alexandr Kamyshev on 27.12.2020.
//

import Foundation
import UIKit

struct ImageViewModel {
    private let imageEntity: ImageEntity
    
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
    
    init(imageEntity: ImageEntity) {
        self.imageEntity = imageEntity
    }
    
    
}
