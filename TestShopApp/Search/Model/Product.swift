//
//  Product.swift
//  TestShopApp
//
//  Created by Vlad on 12.01.2021.
//

import Foundation
import UIKit

class Product { // Класс продукта
    
    let id : Int
    let title : String?
    let short_description : String?
    let imageUrl : String?
    var image : UIImage?
    let amount : Int?
    let price : Double?
    let producer : String?
    let categories : [Category]?
    var countInBag : Int
    
    init(info : ProductInfo) {
        id = info.id
        title = info.title
        short_description = info.short_description
        imageUrl = info.image_url
        amount = info.amount
        price = info.price
        producer = info.producer
        categories = info.categories
        countInBag = 0
    }
    
    init() {
        id = Int()
        title = String()
        short_description = String()
        imageUrl = String()
        amount = Int()
        price = Double()
        producer = String()
        categories = [Category]()
        countInBag = Int()
    }
}
