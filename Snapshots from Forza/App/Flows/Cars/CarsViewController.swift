//
//  CarsViewController.swift
//  Snapshots from Forza
//
//  Created by Ruslan Safargalin on 05.11.2021.
//

import Foundation
import UIKit

final class CarsViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let networkManager: NetworkManager = NetworkManagerImpl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        Task {
            imageView.image = await networkManager.fetchRandomCarImage()
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
}
