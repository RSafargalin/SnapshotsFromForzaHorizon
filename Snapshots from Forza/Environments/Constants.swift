//
//  Constants.swift
//  Snapshots from Forza
//
//  Created by Ruslan Safargalin on 05.11.2021.
//

import Foundation
import UIKit

enum Constant {
    
    enum Manager {
        
        enum Network {
            
            static let basicURL: String = "https://forza-api.tk"
            static let maxActiveTaskOnGroup: Int = 10
            static let maxUniqueImagesCount: Int = 14
            
            enum CacheSettings {
                
                static let maxUsingMemory: UInt64 = 307_200_000
                static let preferredMemoryUsage: UInt64 = 256_000_000
                
            }
        }
        
    }
    
    enum Screens {
        enum Cars {
            static let title = "Cars"
        }
        
        enum Launch {
            enum FontSettings {
                enum Sizes {
                    static let description: CGFloat = 14
                }
            }
        }
    }
    
}
