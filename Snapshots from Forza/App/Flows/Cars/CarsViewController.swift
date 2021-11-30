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
    
    // MARK: - Private properties
    
    private let core: CarsScreenCore = Core.main
    private var isLoading: Bool = false
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureUI()
    }
    
    // MARK: - Init
    // TODO: Разобраться с инициализацией. Where DI, man?
    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
    private func configureCollectionView() {
        self.collectionView.prefetchDataSource = self
        collectionView.register(CarCellImpl.self, forCellWithReuseIdentifier: CarCellImpl.identifier)
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
        
        let identifier = dataStore.images[index]
        let image = core.fetchImage(with: identifier)
        
        cell.configure(from: image)
        
        return cell
    }
    
}

extension CarsViewController: UICollectionViewDelegateFlowLayout {
    
    // TODO: Заменить цифры на константы
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 20
        let height = width / 1.8333
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10,
                            left: 10,
                            bottom: 10,
                            right: 10)
    }
    
}

extension CarsViewController: UICollectionViewDataSourcePrefetching {
    
    // TODO: Вынести логику ограничения запросов в Core
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let indexPath = indexPaths.first else { return }
        if (dataStore.images.count - indexPath.item) <= 10,
           !isLoading {
                Task {
                    isLoading = true
                    dataStore.images.append(contentsOf: await core.downloadNextImagesPart())
                    isLoading = false
                }
        }
    }
}
