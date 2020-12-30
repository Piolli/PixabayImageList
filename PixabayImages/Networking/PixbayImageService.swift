//
//  PixbayImageService.swift
//  PixabayImages
//
//  Created by Alexandr Kamyshev on 27.12.2020.
//

import Foundation
import Combine

class PixbayImageService: ImageServiceProtocol {
    func queryImages(with query: String, pageNumber: Int, imagesPerPage: Int) -> AnyPublisher<[ImageEntity], Error> {
        
        var components = URLComponents(string: "https://pixabay.com/api")!
        components.queryItems = [
            .init(name: "key", value: "19666227-d315f7b8ea029a4082a7feb51"),
            .init(name: "q", value: query),
            .init(name: "image_type", value: "photo"),
            .init(name: "per_page", value: "\(imagesPerPage)"),
            .init(name: "page", value: "\(pageNumber)"),
        ]
        
        let request = URLRequest(url: components.url!)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: ServerResponse.self, decoder: JSONDecoder())
            .map { $0.hits }
            .eraseToAnyPublisher()
    }
}

struct ServerResponse: Decodable {
    let hits: [ImageEntity]
}
