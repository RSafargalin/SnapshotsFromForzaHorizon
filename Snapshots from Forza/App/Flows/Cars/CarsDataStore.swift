//
//  CarsDataStore.swift
//  Snapshots from Forza
//
//  Created by Ruslan Safargalin on 09.11.2021.
//

import Foundation
import UIKit

protocol CarsDataStore {
    
    var owner: CarsViewController? { get set }
    
    var images: [UIImage] { get set }
    
}

struct CarsDataStoreImpl: CarsDataStore {
    
    var images: [UIImage] = [] {
        didSet {
            owner?.collectionView.reloadData()
        }
    }
    
    weak var owner: CarsViewController?
    
    init(owner: CarsViewController) {
        self.owner = owner
    }
}
