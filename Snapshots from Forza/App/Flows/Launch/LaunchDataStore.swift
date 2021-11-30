//
//  LaunchDataStore.swift
//  Snapshots from Forza
//
//  Created by Ruslan Safargalin on 09.11.2021.
//

import Foundation
import UIKit

// TODO: Прикрутить документацию
protocol LaunchDataStore {
    
    var images: [String] { get set }
    
}

struct LaunchDataStoreImpl: LaunchDataStore {
    
    var images: [String] = []
    
}
