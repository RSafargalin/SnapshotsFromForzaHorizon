//
//  LaunchViewController.swift
//  Snapshots from Forza
//
//  Created by Ruslan Safargalin on 08.11.2021.
//

import Foundation
import UIKit

final class LaunchViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: – Public
    
    var dataStore: LaunchDataStore = LaunchDataStoreImpl()
    
    // MARK: – Private
    
    private let networkManager: NetworkManager = NetworkManagerImpl()
    private var router: LaunchScreenRouting = NavigationCenter.main
    
    // MARK: - Views
    
    // MARK: – Private
    
    private lazy var logo: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage.logo
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label: UILabel = UILabel()
        label.numberOfLines = 0
        label.text = "Минуточку, загружаем изображения...\nПри хорошем интернет-соединении загрузка занимает около 20 секунд"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.color = .darkGray
        indicatorView.startAnimating()
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        router.launchViewController = self
        
        loadingImages()
    }
    
    // MARK: - Private methods
    
    private func loadingImages() {
        Task {
            dataStore.images = await networkManager.fetchCarsImages()
            DispatchQueue.main.async {
                self.router.routeTo()
            }
            
        }
    }
    
    // FIXME: Вынести в отдельный метод в NetworkManager
    private func fetchImages() async -> [UIImage] {
        
        actor ImagesStack {
            var images: [UIImage] = []
            
            func append(_ image: UIImage) {
                images.append(image)
            }
        }
        
        let imagesStack: ImagesStack = .init()
        
        let task = Task { () -> [UIImage] in
            for _ in 0...19 {
                let image = await networkManager.fetchRandomCarImage()
                await imagesStack.append(image)
            }
            return await imagesStack.images
        }
        
        return await task.value
    }
    
    // MARK: – UI
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(logo)
        view.addSubview(descriptionLabel)
        view.addSubview(activityIndicator)
        
        let horizontalSpacing: CGFloat = (systemMinimumLayoutMargins.leading + systemMinimumLayoutMargins.trailing) * 2
        
        let defaultLogoSize = CGSize(width: (view.bounds.width - horizontalSpacing),
                                     height: 234)
        
        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logo.widthAnchor.constraint(equalToConstant: defaultLogoSize.width),
            logo.heightAnchor.constraint(equalToConstant: defaultLogoSize.height),
            
            activityIndicator.topAnchor.constraint(equalTo: logo.bottomAnchor,
                                                   constant: 0),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor,
                                                  constant: 25),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                      constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                       constant: -16)
        ])
    }
    
}
