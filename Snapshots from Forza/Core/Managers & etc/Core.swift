//
//  NavigationCenter.swift
//  Snapshots from Forza
//
//  Created by Ruslan Safargalin on 08.11.2021.
//

import Foundation
import UIKit

protocol LaunchScreenCore {
    
    var launchViewController: LaunchViewController? { get set }
    
    func start()
    
    func downloadUniqueImages() async
    
    func downloadFirstImagesPart() async -> [String]
    
}

protocol CarsScreenCore {
    
    func downloadNextImagesPart() async -> [String]

    func fetchImage(with identifier: String) -> UIImage?
    
}

enum NavigationCenterErrors: Error {
    case UIWindowSceneNilOrNotFound,
         SceneDelegateNilOrNotFound,
         UIWindowNilOrNotFound
}

class Core {
    
    static let main: Core = .init()
    
    private init() {}
    
    private let networkManager: NetworkManager = NetworkManagerImpl()
    
    // FIXME: Возможно потенциальное место создания Zombie-объекта, проверить
    private var mainWindow: UIWindow?
    
    // MARK: Public methods
    
    /// Метод инициализации стартового экрана и назначением *view controller'a*
    /// - Returns: Возвращает объект соответствующий классу **UIWindow**
    func start(using windowScene: UIWindowScene) -> UIWindow? {
        mainWindow = UIWindow(windowScene: windowScene)
        mainWindow?.rootViewController = LaunchViewController()
        return mainWindow
    }
    
    
    // MARK: Private methods
    
    private func replaceRootViewController(with viewController: UIViewController) throws {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        else { throw NavigationCenterErrors.UIWindowSceneNilOrNotFound }
        
        guard let sceneDelegate = windowScene.delegate as? SceneDelegate
        else { throw NavigationCenterErrors.SceneDelegateNilOrNotFound }
        
        guard let currentWindow = sceneDelegate.window
        else { throw NavigationCenterErrors.UIWindowNilOrNotFound }
        
        currentWindow.rootViewController = viewController
    }
    
    // MARK: LaunchScreenCore
    
    weak var launchViewController: LaunchViewController?
    
}

// MARK: - Launch Screen Core

extension Core: LaunchScreenCore {
    
    // TODO: Вынести название VC в расширение
    func start() {
        let viewController = CarsViewController()
        
        if let images = launchViewController?.dataStore.images {
            viewController.dataStore.images = images
        }
        
        let navController = UINavigationController(rootViewController: viewController)
        let tabBarViewController = UITabBarController()
        tabBarViewController.setViewControllers([navController], animated: false)
        
        viewController.title = "Cars"
        navController.tabBarItem.image = UIImage.Screens.cars
        tabBarViewController.tabBar.tintColor = .purple
        try? replaceRootViewController(with: tabBarViewController)
    }
    
    func downloadUniqueImages() async {
        await networkManager.downloadUniqueImages()
    }
    
    func downloadFirstImagesPart() async -> [String] {
        return await networkManager.fetchRandomCarImages()
    }
    
}

// MARK: - Cars Screen Core

extension Core: CarsScreenCore {
    
    func downloadNextImagesPart() async -> [String] {
        return await networkManager.fetchRandomCarImages()
    }
    
    func fetchImage(with identifier: String) -> UIImage? {
        return networkManager.getImage(for: identifier)
    }
}
