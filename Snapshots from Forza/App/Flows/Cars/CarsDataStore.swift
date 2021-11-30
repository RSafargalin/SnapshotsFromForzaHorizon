//
//  CarsDataStore.swift
//  Snapshots from Forza
//
//  Created by Ruslan Safargalin on 09.11.2021.
//

import Foundation
import UIKit

// TODO: Прикрутить документацию
protocol CarsDataStore {
    
    var owner: CarsViewController? { get set }
    
    var images: [String] { get set }
    
}

struct CarsDataStoreImpl: CarsDataStore {
    
    var images: [String] = [] {
        didSet {
            owner?.collectionView.reloadData()
        }
    }
    
    weak var owner: CarsViewController?
    
    init(owner: CarsViewController) {
        self.owner = owner
    }
}
