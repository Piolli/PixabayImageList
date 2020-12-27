//
//  ImageEntity.swift
//  PixabayImages
//
//  Created by Alexandr Kamyshev on 27.12.2020.
//

import Foundation

struct ImageEntity: Decodable {
    let id: Int
    let largeImageURL: String
    let imageWidth: Int
    let imageHeight: Int
    let downloads: Int
    let likes: Int
    
    static func empty() -> Self {
        return .init(id: 0, largeImageURL: "", imageWidth: 0, imageHeight: 0, downloads: 0, likes: 0)
    }
}
