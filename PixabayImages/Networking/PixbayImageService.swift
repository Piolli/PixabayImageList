//
//  PixbayImageService.swift
//  PixabayImages
//
//  Created by Alexandr Kamyshev on 27.12.2020.
//

import Foundation
import Combine

class PixbayImageService: ImageServiceProtocol {
    func queryImages(_ query: String) -> AnyPublisher<[ImageEntity], Error> {
        return [[.empty(), .empty()]].publisher
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
