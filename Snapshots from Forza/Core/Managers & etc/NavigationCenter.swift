//
//  NavigationCenter.swift
//  Snapshots from Forza
//
//  Created by Ruslan Safargalin on 08.11.2021.
//

import Foundation
import UIKit

protocol LaunchScreenRouting {
    
    var launchViewController: LaunchViewController? { get set }
    
    func routeTo()
    
}

enum NavigationCenterErrors: Error {
    case UIWindowSceneNilOrNotFound,
         SceneDelegateNilOrNotFound,
         UIWindowNilOrNotFound
}

class NavigationCenter: LaunchScreenRouting {
    
    static let main: NavigationCenter = .init()
    
    private init() {}
    
    func replaceRootViewController(with viewController: UIViewController) throws {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        else { throw NavigationCenterErrors.UIWindowSceneNilOrNotFound }
        
        guard let sceneDelegate = windowScene.delegate as? SceneDelegate
        else { throw NavigationCenterErrors.SceneDelegateNilOrNotFound }
        
        guard let currentWindow = sceneDelegate.window
        else { throw NavigationCenterErrors.UIWindowNilOrNotFound }
        
        currentWindow.rootViewController = viewController
    }
    
    // MARK: - LaunchScreenRouting
    
    weak var launchViewController: LaunchViewController?
    
    func routeTo() {
        let viewController = CarsViewController()
        
        if let images = launchViewController?.dataStore.images {
            viewController.dataStore.images = images
        }
        
        try? replaceRootViewController(with: viewController)
    }
    
}
