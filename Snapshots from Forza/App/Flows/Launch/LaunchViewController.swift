//
//  LaunchViewController.swift
//  Snapshots from Forza
//
//  Created by Ruslan Safargalin on 08.11.2021.
//

import Foundation
import UIKit

final class LaunchViewController: UIViewController {
    
    private typealias GlobalFontsSettings = Constant.Screens.Launch.FontSettings
    private typealias LaunchVCConstraintsConstants = LaunchViewController.Constants.Constraints
    
    private enum Constants {
        enum Constraints {
            static let defaultLeft: CGFloat = 16,
                       defaultRight: CGFloat = -16,
                       spacingBetweenIndicatorAndLogo: CGFloat = 0,
                       spacingBetweenDescriptionAndIndicator: CGFloat = 25
        }
        
        enum Sizes {
            static let defaultLogoHeight: CGFloat = 234
        }
    }
    
    // MARK: - Properties
    
    // MARK: – Public
    
    let dataStore: LaunchDataStore
    
    // MARK: – Private
    
    private var core: LaunchScreenCore = Core.main
    
    // MARK: - Views
    
    // MARK: – Private
    
    private lazy var logo: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage.logo
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // TODO: Добавить локализацию
    private lazy var descriptionLabel: UILabel = {
        let label: UILabel = UILabel()
        label.numberOfLines = 0
        label.text = "Минуточку, загружаем изображения...\nПри хорошем интернет-соединении загрузка занимает около 20 секунд"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: GlobalFontsSettings.Sizes.description)
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
    
    // MARK: - Init
    
    init(with dataStore: LaunchDataStore) {
        self.dataStore = dataStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        core.launchViewController = self
        
        loadingImages()
    }
    
    // MARK: - Private methods
    
    private func loadingImages() {
        Task {
            await core.downloadUniqueImages()
            dataStore.images = await core.downloadFirstImagesPart()
            DispatchQueue.main.async {
                self.core.start()
            }
        }
    }
    
    // MARK: – UI
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(logo)
        view.addSubview(descriptionLabel)
        view.addSubview(activityIndicator)
        
        let horizontalSpacing: CGFloat = (systemMinimumLayoutMargins.leading + systemMinimumLayoutMargins.trailing) * 2
        
        let defaultLogoSize = CGSize(width: (view.bounds.width - horizontalSpacing),
                                     height: LaunchViewController.Constants.Sizes.defaultLogoHeight)
        
        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logo.widthAnchor.constraint(equalToConstant: defaultLogoSize.width),
            logo.heightAnchor.constraint(equalToConstant: defaultLogoSize.height),
            
            activityIndicator.topAnchor.constraint(equalTo: logo.bottomAnchor,
                                                   constant: LaunchVCConstraintsConstants.spacingBetweenIndicatorAndLogo),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor,
                                                  constant: LaunchVCConstraintsConstants.spacingBetweenDescriptionAndIndicator),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                      constant: LaunchVCConstraintsConstants.defaultLeft),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                       constant: LaunchVCConstraintsConstants.defaultRight)
        ])
    }
    
}
