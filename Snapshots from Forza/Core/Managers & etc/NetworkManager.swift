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
    
}

final class NetworkManagerImpl: NetworkManager {
    
    // MARK: Typealias
    
    private typealias NetworkConstants = Constant.Manager.Network
    
    // MARK: Public methods
    
    func fetchRandomCarImage() async -> UIImage {
        guard let imageURL = try? await fetchRandomImageURL(),
              let image = try? await fetchImage(from: imageURL)
        else { return UIImage() }
        print(imageURL)
        return image
    }
    
    // TODO: Метод для получения разных изображений
    func fetchCarsImages() async -> [UIImage] {
        return [UIImage()]
    }
    
    // MARK: Private methods
    
    private func fetchRandomImageURL() async throws -> String {
        try await withUnsafeThrowingContinuation { continuation in
            AF.request(NetworkConstants.basicURL).responseDecodable(of: Car.self) { response in
                switch response.result {
                    case .success(let car):
                        return continuation.resume(returning: car.image)
                        
                    case .failure(let error):
                        return continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func fetchImage(from urlString: String) async throws -> UIImage? {
        try await withUnsafeThrowingContinuation { continuation in
            AF.request(urlString).responseImage { response in
                switch response.result {
                    case .success(let image):
                        return continuation.resume(returning: image)
                        
                    case .failure(let error):
                        return continuation.resume(throwing: error)
                }
            }
        }
    }
    
}


