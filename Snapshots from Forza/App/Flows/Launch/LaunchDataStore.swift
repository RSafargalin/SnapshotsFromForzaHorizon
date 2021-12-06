//
//  LaunchDataStore.swift
//  Snapshots from Forza
//
//  Created by Ruslan Safargalin on 09.11.2021.
//

import Foundation
import UIKit

// TODO: Прикрутить документацию
protocol LaunchDataStore: AnyObject {
    
    var images: [String] { get set }
    
}

class LaunchDataStoreImpl: LaunchDataStore {
    
    var images: [String] = []
    
}
