//
//  ProductsListRequest.swift
//  TestShopApp
//
//  Created by Vlad on 11.01.2021.
//

import Foundation

enum allProductsError: Error { // Ошибки при запросе списка товаров
    case NoDataAvailable
    case CanNotProcessData
}

struct allProductsDataProvider { // Получение данных
    
    let resourceURL : URL
    
    init(pause: Int, count : Int, searchBarInput : String){
        
        var resourceString = String()
        if (searchBarInput == ""){
            resourceString = "https://rstestapi.redsoftdigital.com/api/v1/products?startFrom=\(pause)&maxItems=\(count)&sort=-price"
        } else {
            resourceString = "https://rstestapi.redsoftdigital.com/api/v1/products?filter%5Btitle%5D=\(String(describing: searchBarInput.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!))&startFrom=\(pause)&maxItems=\(count)&sort=-price"
        }
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        self.resourceURL = resourceURL
    }
    
    func getCurrentList(completion: @escaping(Result<[Product], allProductsError>) -> Void) {   
        let dataTask = URLSession.shared.dataTask(with: resourceURL) { (data, _, _) in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            do{
                var output = [Product]()
                let Ans = try JSONDecoder().decode(GetData.self, from: jsonData).data
                Ans.forEach { (ProductInfo) in
                    output.append(Product(info: ProductInfo))
                }
                completion(.success(output))
            } catch {
                completion(.failure(.CanNotProcessData))
            }
        }
        dataTask.resume()
    }
}
