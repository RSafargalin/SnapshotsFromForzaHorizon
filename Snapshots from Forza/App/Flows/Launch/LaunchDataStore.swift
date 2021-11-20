//
//  LaunchDataStore.swift
//  Snapshots from Forza
//
//  Created by Ruslan Safargalin on 09.11.2021.
//

import Foundation
import UIKit

protocol LaunchDataStore {
    
    var images: [UIImage] { get set }
    
}

struct LaunchDataStoreImpl: LaunchDataStore {
    
    var images: [UIImage] = []
    
}
