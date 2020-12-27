//
//  ImageServiceProtocol.swift
//  PixabayImages
//
//  Created by Alexandr Kamyshev on 27.12.2020.
//

import Foundation
import Combine

protocol ImageServiceProtocol {
    func queryImages(_ query: String) -> AnyPublisher<[ImageEntity], Error>
}

