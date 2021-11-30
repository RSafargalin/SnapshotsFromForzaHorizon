//
//  NetworkManager.swift
//  Snapshots from Forza
//
//  Created by Ruslan Safargalin on 05.11.2021.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

// TODO: Прикрутить документацию
protocol NetworkManager: AnyObject {
    
    func getImage(for urlString: String) -> UIImage? 
    
    func fetchRandomCarImages() async -> [String]
    
    func downloadUniqueImages() async
}

enum NetworkManagerError: Error {
    case badURL,
         badData
}

actor ImagesStack {
    var images: [UIImage] = []
    
    func append(_ image: UIImage) {
        images.append(image)
    }
}

actor ImagesURLStack {
    var urlStrings: [String] = []
    
    func append(_ urlString: [String]) {
        urlStrings.append(contentsOf: urlString)
    }
}

actor OptionalsImagesUrls {
    var urls: [String?] = []
    var taskCount: Int = 0
    
    func append(_ urlString: String?) {
        urls.append(urlString)
    }
    
    func incrementTaskCount() {
        taskCount += 1
    }
    
    func decrementTaskCount() {
        if taskCount >= 1 {
            taskCount -= 1
        }
    }
    
    func fetchURLs() -> [String] {
        return urls.compactMap({$0})
    }
    
}

// TODO: Выбросить константы в отдельный файл
// TODO: Реализовать настройку размера кэша изображений
final class NetworkManagerImpl: NetworkManager {
    
    // MARK: Typealias
    
    private typealias NetworkConstants = Constant.Manager.Network
    private let imageCache = AutoPurgingImageCache(memoryCapacity: 307_200_000, preferredMemoryUsageAfterPurge: 256_000_000)
   
    
    private var imagesURL = [String]()
    
    // MARK: Properties
    
    // MARK: Public methods
    
    func downloadUniqueImages() async {
        let imagesURLs = await fetchUniqueImagesURLs()
        await fetchUniqueImages(from: imagesURLs)
    }
    
    private func fetchUniqueImages(from imagesURLs: [String]) async {
        return await withThrowingTaskGroup(of: Void.self, body: { group -> Void in
            let stack: ImagesStack = .init()
            
            imagesURLs.forEach { imageURL in
                group.addTask { [weak self] in
                    if let image = try await self?.fetchImage(from: imageURL) {
                        await stack.append(image)
                    }
                }
            }
            
            try? await group.waitForAll()
        })
    }
    
    private func fetchUniqueImagesURLs() async -> [String] {
        return await withThrowingTaskGroup(of: Void.self, body: { group -> [String] in
            let stack: OptionalsImagesUrls = .init()
            
            while await stack.urls.count <= Constant.Manager.Network.maxUniqueImagesCount {
                if await stack.taskCount >= Constant.Manager.Network.maxActiveTaskOnGroup {
                    try? await group.waitForAll()
                }
                
                group.addTask(priority: .utility) { [weak self] in
                    await stack.incrementTaskCount()
                    
                    if let urlString = try await self?.fetchRandomImageURL(),
                       URL(string: urlString) != nil,
                       await !stack.urls.contains(urlString) {
                            await stack.append(urlString)
                    }
                    
                    await stack.decrementTaskCount()
                }
            }
            
            group.cancelAll()
            
            return await stack.fetchURLs()
        })
    }
    
    // TODO: Добавить возможность загружать определенное количество URL(добавить параметр count)
    func fetchRandomCarImages() async -> [String] {
        return await withTaskGroup(of: Void.self, body: { group -> [String] in
            let stack = ImagesURLStack()
            
           (0...19).forEach { index in
                group.addTask(priority: .utility) { [weak self] in
                    if let urlString = try? await self?.fetchRandomImageURL(),
                       URL(string: urlString) != nil {
                            await stack.append([urlString])
                    }
                }
            }
            
            await group.waitForAll()
            
            return await stack.urlStrings
        })
    }
    
    // TODO: Добавить статику
    func getImage(for urlString: String) -> UIImage? {
        if let image = imageCache.image(withIdentifier: urlString) {
            return image
        } else {
            Task {
                let _ = try? await fetchImage(from: urlString)
            }
            return UIImage(named: "logo")
        }
    }

    // MARK: Private methods
    
    private func fetchRandomImageURL() async throws -> String {
        try await withUnsafeThrowingContinuation { continuation in
            AF.request(NetworkConstants.basicURL).responseDecodable(of: Car.self) { response in
                switch response.result {
                    case .success(let car):
                        return continuation.resume(returning: car.image)
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        return continuation.resume(throwing: error)
                }
            }
        }
    }
    
    
    private func fetchImage(from urlString: String) async throws -> UIImage? {
        try await withUnsafeThrowingContinuation { continuation in
            if let image = imageCache.image(withIdentifier: urlString) {
                return continuation.resume(returning: image)
            }
            
            AF.request(urlString).responseImage { [weak self] response in
                switch response.result {
                    case .success(let image):
                        self?.imageCache.add(image, withIdentifier: urlString)
                        return continuation.resume(returning: image)
                        
                    case .failure(let error):
                        if error.isInvalidURLError {
                            #warning("TODO: разобраться с битыми URL")
                            print(error.localizedDescription)
                            return continuation.resume(throwing: error)
                        } else {
                            print(error.localizedDescription)
                            return continuation.resume(throwing: error)
                        }
                }
            }
        }
    }
    
}
