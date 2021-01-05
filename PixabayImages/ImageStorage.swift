//
//  ImageStorage.swift
//  PixabayImages
//
//  Created by Alexandr Kamyshev on 04.01.2021.
//

import Foundation
import Kingfisher
import Combine
import UIKit

enum ImageStorageError: Error {
    case emptyCache
}

protocol ImageStorage {
    func save(image: UIImage, for key: URL)
    func fetch(with url: URL) -> AnyPublisher<UIImage?, ImageStorageError>
}

class BuiltInImageStorage: ImageStorage {
    
    let cache = NSCache<AnyObject, UIImage>()
    
    init() {
        cache.countLimit = 20
    }
    
    func save(image: UIImage, for key: URL) {
        cache.setObject(image, forKey: key as AnyObject)
    }
    
    func fetch(with url: URL) -> AnyPublisher<UIImage?, ImageStorageError> {
        return Future { [cache] (promise) in
            if let image = cache.object(forKey: url as AnyObject) {
                promise(.success(image))
            } else {
                promise(.failure(.emptyCache))
            }
        }.subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
}
