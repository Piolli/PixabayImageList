//
//  ImagesViewModel.swift
//  PixabayImages
//
//  Created by Alexandr Kamyshev on 26.12.2020.
//

import Foundation
import Combine

class ImagesViewModel: ObservableObject {
    @Published var inputQuery: String = ""
    @Published private(set) var imageViewModels: [ImageViewModel] = []

    private var subscriptions: Set<AnyCancellable> = []
    private let imagesService: ImageServiceProtocol
    
    init(imagesService: ImageServiceProtocol = PixbayImageService()) {
        self.imagesService = imagesService
        $inputQuery
            .sink { [unowned self] (value) in
            self.fetchImages(with: value)
        }.store(in: &subscriptions)
    }
    
    private func fetchImages(with query: String) {
        imagesService.queryImages(with: query, pageNumber: 1, imagesPerPage: 20).sink { (completion) in
            switch completion {
            case .finished:
                print("task has finished")
            case .failure(let error):
                print("task has finished with error: \(error)")
            }
        } receiveValue: { [weak self] (images) in
            self?.imageViewModels = images.map { ImageViewModel(imageEntity: $0) }
        }.store(in: &subscriptions)

    }
    
    func imageViewModel(at indexPath: IndexPath) -> ImageViewModel {
        return imageViewModels[indexPath.row]
    }    
}






