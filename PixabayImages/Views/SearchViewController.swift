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
    private let viewModel: ImagesViewModel = ImagesViewModel()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(ImageViewCell.self, forCellReuseIdentifier: ImageViewCell.identifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = UITableView.automaticDimension
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()

        setUpSearchBar()
        setUpTableView()
    }
    
    func bindViewModel() {
        viewModel.$imageViewModels
            .receive(on: RunLoop.main)
            .sink { [weak self] (images) in
                self?.tableView.reloadData()
            }
        .store(in: &subscriptions)
    }
    
    func setUpSearchBar() {
        searchBarView.searchTextField.returnKeyType = .done
        searchBarView.searchTextField.textPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .assign(to: \.inputQuery, on: viewModel)
            .store(in: &subscriptions)
    }
    
    func setUpTableView() {
        let margins = view.safeAreaLayoutGuide
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
        ])
    }
}

extension SearchImagesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.imageViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageViewCell.identifier, for: indexPath) as! ImageViewCell
        cell.viewModel = viewModel.imageViewModel(at: indexPath)
        return cell
    }
}

/// Another way to adjust cell's height based on imageSize
//extension SearchImagesViewController {
//  var sizes: [URL: CGSize] = [:]
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: ImageViewCell.identifier, for: indexPath) as! ImageViewCell
//        cell.viewModel = viewModel.imageViewModel(at: indexPath)
//        cell.completion = { [unowned self] in
//            if self.sizes[viewModel.imageViewModel(at: indexPath).imageURL!] == nil {
//                self.sizes[self.viewModel.imageViewModel(at: indexPath).imageURL!] = viewModel.imageViewModel(at: indexPath).imageSize
//                tableView.reloadRows(at: [indexPath], with: .automatic)
//            }
//        }
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard let imageSize = sizes[viewModel.imageViewModel(at: indexPath).imageURL!] else {
//            return UITableView.automaticDimension
//        }
//        let screenW = tableView.frame.width
//        let scale = screenW / imageSize.width
//        let nHeight = scale * imageSize.height
//        let ratio = nHeight / screenW
//        return nHeight
//    }
//}

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField } //
            .map { $0.text ?? "" }
            .eraseToAnyPublisher()
    }
}
