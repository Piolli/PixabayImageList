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
    func loadImage(with url: URL) -> AnyPublisher<UIImage?, ImageLoaderError>
}

enum ImageLoaderError: Error {
    case storageError(ImageStorageError)
    case loaderError(URLError)
    case unknown(Error)
}


class KingfisherLoader: ImageLoader {
    func loadImage(with url: URL) -> AnyPublisher<UIImage?, ImageLoaderError> {
        return Future<UIImage?, ImageLoaderError> { (promise) in
            KingfisherManager.shared.retrieveImage(with: url) { result in
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
    
    func loadImage(with url: URL) -> AnyPublisher<UIImage?, ImageLoaderError> {
        return imageStorage.fetch(with: url)
            .catch({  _ in
                URLSession.shared.dataTaskPublisher(for: url)
                    .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                    .map { UIImage(data: $0.data) }
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
}
