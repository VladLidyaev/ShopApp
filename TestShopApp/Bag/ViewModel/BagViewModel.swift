//
//  BagViewModel.swift
//  TestShopApp
//
//  Created by Vlad on 14.01.2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class BagViewModel {
    
    var dataProduct : [BagProductModel] // Данные о всех товарах в корзине
    var data : BehaviorRelay<[BagProductModel]>
    
    var allCount : Int // Общее количесвто товаров
    
    init(info : [productInBag]) {
        allCount = 0
        dataProduct = [BagProductModel]()
        data = BehaviorRelay<[BagProductModel]>(value: dataProduct)
        info.forEach { (productData) in
            dataProduct.append(BagProductModel(name: productData.name, producer: productData.producer, image: UIImage(systemName: "\(productData.count).circle")!))
            allCount += productData.count
        }
        data = BehaviorRelay<[BagProductModel]>(value: dataProduct)
    }
}
