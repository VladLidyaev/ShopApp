//
//  AllProductsRequestDecodable.swift
//  TestShopApp
//
//  Created by Vlad on 11.01.2021.
//

import Foundation // Структуры для декодирования ответа с сервера

struct Category : Decodable {
    let id : Int?
    let title : String?
    let parent_id : Int?
}

struct ProductInfo : Decodable {
    let id : Int
    let title : String
    let short_description : String
    let image_url : String
    let amount : Int
    let price : Double
    let producer : String
    let categories : [Category]
}

struct GetData : Decodable {
    let data : [ProductInfo]
}
