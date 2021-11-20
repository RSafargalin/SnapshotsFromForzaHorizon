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

protocol NetworkManager: AnyObject {
    
    func fetchRandomCarImage() async -> UIImage
    
    func fetchCarsImages() async -> [UIImage]
    
    func get(count: Int) async -> [String]
    
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

final class NetworkManagerImpl: NetworkManager {
    
    // MARK: Typealias
    
    private typealias NetworkConstants = Constant.Manager.Network
    private let imageCacher = ResponseCacher(behavior: .cache)
    private let imageCache = AutoPurgingImageCache()
    
    private var imagesURL = [String]()
    
    // MARK: Properties
    
    // MARK: Public methods
    
    func fetchRandomCarImage() async -> UIImage {
        guard let imageURL = try? await fetchRandomImageURL(),
              let image = try? await fetchImage(from: imageURL)
        else { return UIImage() }
        return image
    }
    
    // TODO: Метод для получения разных изображений
    func fetchCarsImages() async -> [UIImage] {
        let imagesStack: ImagesStack = .init()
        
        let task = Task { () -> [UIImage] in
            for _ in 0...19 {
                let image = await fetchRandomCarImage()
                await imagesStack.append(image)
            }
            return await imagesStack.images
        }
        
        return await task.value
    }
    
    // TODO: Метод получения уникальных изображений. Рефакторинг+
    func get(count: Int) async -> [String] {
        let stack: ImagesURLStack = .init()
        
        if count == 1 {
            if let imageURL = try? await fetchRandomImageURL(),
               !imagesURL.contains(where: { $0 == imageURL }) {
                imagesURL.append(imageURL)
                await stack.append([imageURL])
                
            } else {
                await stack.append(await get(count: 1))
            }
        } else {
            return await Task { () -> [String] in
                var temp = [String]()
                
                await temp.append(contentsOf: get(count: count - 1))
                if let imageURL = try? await fetchRandomImageURL(),
                   !imagesURL.contains(where: { $0 == imageURL }) {
                    imagesURL.append(imageURL)
                    temp.append(imageURL)
                } else {
                    temp.append(contentsOf: await get(count: 1))
                }
                return temp
            }.value
        }
        
        return await stack.urlStrings
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
            
            AF.request(urlString).cacheResponse(using: imageCacher).responseImage { [weak self] response in
                switch response.result {
                    case .success(let image):
                        self?.imageCache.add(image, withIdentifier: urlString)
                        return continuation.resume(returning: image)
                        
                    case .failure(let error):
                        if error.isInvalidURLError {
                            guard let url = URL(string: urlString)
                            else {
                                print(NetworkManagerError.badURL, urlString)
                                return continuation.resume(throwing: NetworkManagerError.badURL)
                            }
                            URLSession.shared.dataTask(with: url) { (data, response, error) in
                                guard let data = data else { return continuation.resume(throwing: NetworkManagerError.badData) }
                                return continuation.resume(returning: UIImage(data: data))
                            }
                        } else {
                            print(error.localizedDescription)
                            return continuation.resume(throwing: error)
                        }
                }
            }
        }
    }
    
    
    private func fetchImageUsingDefaultInstrument(from urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else { throw NetworkManagerError.badURL }
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else { throw NetworkManagerError.badData }
        return image
    }
    
}
