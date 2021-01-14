//
//  ImageRequest.swift
//  TestShopApp
//
//  Created by Vlad on 12.01.2021.
//

import Foundation
import UIKit

enum imageError: Error { // Ошибки при получении изображения
    case NoDataAvailable
}

struct imageDataProvider { // Получение изображения
    
    var imageCache = NSCache<NSString,UIImage>()
    let resourceURL : URL
    
    init(imageUrl : String){
        guard let resourceURL = URL(string: imageUrl) else {fatalError()}
        self.resourceURL = resourceURL
    }
    
    func getImage(completion: @escaping(Result<(url : URL,image : UIImage), imageError>) -> Void) {
        
        if let cacheImage = imageCache.object(forKey: resourceURL.absoluteString as NSString) {
            completion(.success((url : resourceURL,image : cacheImage)))
        } else {
            let dataTask = URLSession.shared.dataTask(with: resourceURL) { (data, _, _) in
                guard let image = UIImage(data: data!) else {
                    completion(.failure(.NoDataAvailable))
                    return
                }
                self.imageCache.setObject(image, forKey: resourceURL.absoluteString as NSString)
                completion(.success((url : resourceURL,image : image)))
            }
            dataTask.resume()

        }
    }
}
