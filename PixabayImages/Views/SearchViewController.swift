//
//  ViewController.swift
//  PixabayImages
//
//  Created by Alexandr Kamyshev on 26.12.2020.
//

import UIKit
import Combine

class SearchImagesViewController: UIViewController {
    
    @IBOutlet weak var searchBarView: UISearchBar!
    private var subscriptions: Set<AnyCancellable> = []
    let viewModel: ImagesViewModel = ImagesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarView.searchTextField.textPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .assign(to: \.inputQuery, on: viewModel)
            .store(in: &subscriptions)
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel.$imageViewModels.sink { (images) in
            print("images: \(images)")
        }.store(in: &subscriptions)
    }
}

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField } //
            .map { $0.text ?? "" }
            .eraseToAnyPublisher()
    }
}
