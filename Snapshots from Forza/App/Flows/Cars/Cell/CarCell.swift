//
//  CarCell.swift
//  Snapshots from Forza
//
//  Created by Ruslan Safargalin on 09.11.2021.
//

import Foundation
import UIKit

// TODO: Прикрутить документацию
protocol CarCell: UICollectionViewCell {
    
    static var identifier: String { get }
    
    func configure(from image: UIImage?)
    
}

final class CarCellImpl: UICollectionViewCell, CarCell {
    
    // MARK: - Properties
    
    // MARK: – Public
    
    static let identifier: String = "CarCell"
    
    // MARK: – Private
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    // MARK: – Public
    
    func configure(from image: UIImage?) {
        imageView.image = image
    }

    override func prepareForReuse() {
        imageView.image = nil
    }
    
    // MARK: – Private
    
    private func configureUI() {
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }

}
