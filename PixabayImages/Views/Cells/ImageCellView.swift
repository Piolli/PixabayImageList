//
//  ImageCellView.swift
//  PixabayImages
//
//  Created by Alexandr Kamyshev on 30.12.2020.
//

import Foundation
import Combine
import UIKit

class ImageViewCell: UITableViewCell {
    
    static let identifier = String(describing: ImageViewCell.self)
    private var aspectConstraint: NSLayoutConstraint!
    private var subscription: Cancellable!
    
    lazy var mainImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var likeLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var downloadsLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .right
        return view
    }()

    var viewModel: ImageViewModel! {
        didSet {
            setUpViewModel()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if aspectConstraint != nil {
            mainImageView.removeConstraint(aspectConstraint)
        }
        subscription.cancel()
        mainImageView.image = nil
    }
    
    private func setUp() {
        contentView.addSubview(mainImageView)
        contentView.addSubview(likeLabel)
        contentView.addSubview(downloadsLabel)

        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            mainImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            mainImageView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            mainImageView.topAnchor.constraint(equalTo: margins.topAnchor),

            likeLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor),
            likeLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            likeLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor),

            downloadsLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            downloadsLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor),
            downloadsLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor),

            likeLabel.widthAnchor.constraint(equalTo: downloadsLabel.widthAnchor),
            likeLabel.trailingAnchor.constraint(equalTo: downloadsLabel.leadingAnchor, constant: 8)
        ])
    }
    
    private func setUpViewModel() {
        mainImageView.accessibilityIdentifier = "MainImageView"
        likeLabel.text = viewModel.likeText
        downloadsLabel.text = viewModel.downloadsText
        
        //aspect constraint
        aspectConstraint = mainImageView.heightAnchor.constraint(equalTo: mainImageView.widthAnchor, multiplier: viewModel.aspectRatio)
//        print("ratio:", viewModel.aspectRatio)
        aspectConstraint.priority = .init(999)
        aspectConstraint.accessibilityLabel = "aspectConstraint"
        aspectConstraint.identifier = "aspectConstraint"
        aspectConstraint.isActive = true
        
        guard let imageURL = viewModel.imageURL else {
            return
        }
        
        subscription = viewModel
            .fetchImage()
            .filter { _ in
                assert(imageURL == self.viewModel.imageURL)
                return imageURL == self.viewModel.imageURL
            }
            .assertNoFailure()
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: mainImageView)
    }
    
    func printViewHierarchy(_ view: UIView) {
        for sub in view.subviews {
            if sub.hasAmbiguousLayout {
                printViewHierarchy(sub)
            }
        }
    }
}


