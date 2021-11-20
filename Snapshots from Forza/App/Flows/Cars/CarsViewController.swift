//
//  CarsViewController.swift
//  Snapshots from Forza
//
//  Created by Ruslan Safargalin on 05.11.2021.
//

import Foundation
import UIKit

final class CarsViewController: UICollectionViewController {
    
    // MARK: – Public
    
    lazy var dataStore: CarsDataStore = CarsDataStoreImpl(owner: self)
    
    private let networkManager: NetworkManager = NetworkManagerImpl()
    private var isLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        self.collectionView.prefetchDataSource = self
        
        Task {
            print(await networkManager.get(count: 16))
        }
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
        collectionView.register(CarCellImpl.self, forCellWithReuseIdentifier: CarCellImpl.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
    //
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataStore.images.count
    }
    
    // FIXME: Возвращать ячейку-заглушку
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarCellImpl.identifier, for: indexPath) as? CarCellImpl
        else { return UICollectionViewCell() }

        let index = indexPath.item
        
        guard index >= dataStore.images.startIndex && index <= dataStore.images.endIndex
        else { return UICollectionViewCell() }
        
        let image = dataStore.images[index]
        
        cell.configure(from: image)
        
        return cell
    }
    
}

extension CarsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 20
        let height = width / 1.8333
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
}

extension CarsViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.count <= 10,
           !isLoading {
            Task {
                isLoading = true
                dataStore.images.append(contentsOf: await networkManager.fetchCarsImages())
                isLoading = false
//                collectionView.reloadData()
            }
            
        }
    }
    
    
}
