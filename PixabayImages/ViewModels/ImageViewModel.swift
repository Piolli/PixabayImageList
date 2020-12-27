//
//  ImageViewModel.swift
//  PixabayImages
//
//  Created by Alexandr Kamyshev on 27.12.2020.
//

import Foundation

struct ImageViewModel {
    private let imageEntity: ImageEntity
    
    init(imageEntity: ImageEntity) {
        self.imageEntity = imageEntity
    }
}
