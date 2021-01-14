//
//  SerchViewModel.swift
//  TestShopApp
//
//  Created by Vlad on 12.01.2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SearchViewModel{
    
    var errorCondition = BehaviorRelay<Bool>(value: false)
    
    var searchText = BehaviorRelay(value: "")
    var data : BehaviorRelay<[Product]>
    var actualDataArray : [Product]
    var bagArray : [productInBag]
    var viewLenght = 0 // Номер ячейки, до прохождения которой, мы не отправляем новый запрос
    
    var visiblecellsindexpath : BehaviorRelay<Int>
    let DBag = DisposeBag()
    let radiusOfDownloadCells = 40
    var isLoadingSmthNow = (value : 0, isStarting : false)
    
    init() {
        data = BehaviorRelay<[Product]>(value: [])
        actualDataArray = [Product]()
        bagArray = [productInBag]()
        visiblecellsindexpath = BehaviorRelay<Int>.init(value: 0)
        searchReload()
        visibleCells()
    }
    
    func searchReload() { // Отправка запроса
        self.searchText
            .asObservable()
            .subscribe { [self] (search) in
                actualDataArray = [Product]()
                viewLenght = 0
                self.reloadData(from: 0, count: radiusOfDownloadCells, search: search.element ?? "", searchFlag: true)
            }.disposed(by: DBag)
    }
    
    func visibleCells(){ // Получение индекса видимых ячеек
        visiblecellsindexpath
            .asObservable()
            .distinctUntilChanged()
            .subscribe { [self] (position) in
                DispatchQueue.global(qos: .userInteractive).async {
                    self.reloadData(from: position.element!, count: radiusOfDownloadCells, search: searchText.value, searchFlag: false )
                }
            }.disposed(by: DBag)
    }
    
    func sendInfoInBag(data : productInBag){
        var bag = [productInBag]()
        var isContenet = false
        bagArray.forEach { (note) in
            if (note.count > 0) {
                if (note.id == data.id) {
                    isContenet = true
                    if (data.count > 0) {
                        bag.append(data)
                    }
                } else { bag.append(note)}
            }
        }
        if !isContenet && (data.count > 0) {
            bag.append(data)
        }
        self.bagArray = bag
    }
    
    func getCountById(id : Int) -> Int {
        var ans = 0
        bagArray.forEach { (note) in
            if (id == note.id) {
                ans = note.count } }
        return ans
    }
    
    func reloadData(from : Int, count : Int, search : String, searchFlag : Bool) { // Получение данных
        if (viewLenght <= from ) || (searchFlag) {
            viewLenght += count/4
            allProductsDataProvider(pause: from, count: count, searchBarInput: search).getCurrentList { [self] (result) in
                switch result {
                case .success(let out):
                    var dataDuplicate = actualDataArray
                    out.forEach { (product) in
                        if (!isContent(element: product, arr: dataDuplicate)){
                            dataDuplicate.append(product)
                        }
                    }
                    if (search == searchText.value) {
                        self.data.accept(dataDuplicate)
                    }
                    let semaphore = DispatchSemaphore(value: 0)
                    DispatchQueue.global(qos: .userInitiated).async {
                        out.forEach { (Product) in
                            if (search == searchText.value) {
                                isLoadingSmthNow.isStarting = true
                                isLoadingSmthNow.value += 1
                                imageDataProvider(imageUrl: Product.imageUrl!).getImage {(result) in
                                    switch result {
                                    case .success(( _, let image)):
                                        isLoadingSmthNow.value -= 1
                                        Product.image = image
                                        if (search == searchText.value) && (!isContent(element: Product, arr: actualDataArray)){
                                            actualDataArray.append(Product)
                                        }
                                        semaphore.signal()
                                    case .failure(_):
                                        isLoadingSmthNow.value -= 1
                                        Product.image = UIImage(named: "noImage.jpg")
                                        if (search == searchText.value) && (!isContent(element: Product, arr: actualDataArray)){
                                            actualDataArray.append(Product)
                                        }
                                        semaphore.signal()
                                    }
                                }
                            }
                            semaphore.wait()
                        }
                        if (search == searchText.value) {
                            data.accept(actualDataArray)
                        }
                    }
                case .failure(_):
                    errorCondition.accept(true)
                }
            }
        }
    }

    private func isContent(element : Product, arr : [Product]) -> Bool {
        var isContent = false
        arr.forEach { (ProductElement) in
            if (ProductElement.id == element.id){
                isContent = true
            }
        }
        return isContent
    }
}
