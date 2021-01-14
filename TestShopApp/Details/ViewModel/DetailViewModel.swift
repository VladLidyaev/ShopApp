//
//  DetailViewModel.swift
//  TestShopApp
//
//  Created by Vlad on 13.01.2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class DetailViewModel { // Подготовка данных для VC
    
    var id : Int
    var countInBag : Int
    var title : String
    var description : String
    var producer : String
    var price : String
    var image : UIImage
    var categories : [String]
    var countRelay = BehaviorRelay<Int>(value : 0)
    
    init(info: Product) {
        self.title = info.title ?? "No title"
        self.id = info.id
        self.countInBag = info.countInBag
        self.description = info.short_description ?? "No description"
        self.producer = info.producer ?? "No producer"
        self.price = (String(info.price ?? 00.00)) + " ₽"
        self.categories = [String]()
        self.image = info.image ?? UIImage(named: "noImage.jpg")!
        info.categories?.forEach({ (Category) in
            self.categories.append(Category.title!)
        })
        countRelay.accept(info.countInBag)
    }
    
}
