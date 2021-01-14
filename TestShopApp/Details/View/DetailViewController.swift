//
//  DetailViewController.swift
//  TestShopApp
//
//  Created by Vlad on 13.01.2021.
//

import UIKit
import RxCocoa
import RxSwift

class DetailViewController: UIViewController {
    
    @IBOutlet weak var producerLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var backgroundViewForCategories: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var backgroundViewForButton: UIView!
    
    var productInfo : Product!
    var DBag = DisposeBag()
    
    private let buttonLabelStepperColor = UIColor.systemBlue
    private let allBackgroundColor = UIColor.systemBackground
    private let allTextColor = UIColor.white
    private let CornerRadius = CGFloat(10)
    private let buttonStepperRadius = CGFloat(6)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureProperties()
        
        let viewModel = DetailViewModel(info: productInfo)
        navigationItem.title = viewModel.title
        producerLabel.text = viewModel.producer
        productImage.image = viewModel.image
        descriptionLabel.text = viewModel.description
        priceLabel.text = viewModel.price
        
        let labelDetail = UILabel(frame: CGRect(x: self.backgroundViewForButton.center.x-180, y: self.backgroundViewForButton.center.y-320, width: 30, height: 30)) // Отображение количества продуктов в корзине
            labelDetail.textAlignment = .center
            labelDetail.textColor = allTextColor
            labelDetail.backgroundColor = buttonLabelStepperColor
            labelDetail.layer.masksToBounds = true
            labelDetail.text = String(productInfo.countInBag)
            labelDetail.layer.cornerRadius = 15
            self.backgroundViewForButton.addSubview(labelDetail)

        let stepperDetail = UIStepper(frame: CGRect(x: self.backgroundViewForButton.center.x-244, y: self.backgroundViewForButton.center.y-25, width: 94, height: 32)) // Степпер добавления продуктов в корзину
            stepperDetail.backgroundColor = buttonLabelStepperColor
            stepperDetail.setDecrementImage(stepperDetail.decrementImage(for: .normal), for: .normal)
            stepperDetail.setIncrementImage(stepperDetail.incrementImage(for: .normal), for: .normal)
            stepperDetail.tintColor = allTextColor
            stepperDetail.layer.cornerRadius = buttonStepperRadius
            stepperDetail.maximumValue = 20
            stepperDetail.minimumValue = 0
            stepperDetail.value = Double(viewModel.countInBag)
            self.backgroundViewForButton.addSubview(stepperDetail)

        let buttonDetail = UIButton(frame: CGRect(x: self.backgroundViewForButton.center.x-244, y: self.backgroundViewForButton.center.y-25, width: 94, height: 32)) // Кнопка добавления продуктов в корзину
            buttonDetail.backgroundColor = buttonLabelStepperColor
            buttonDetail.layer.cornerRadius = buttonStepperRadius
            buttonDetail.setImage(UIImage(systemName: "bag.badge.plus"), for: .normal)
            buttonDetail.tintColor = allBackgroundColor
            self.backgroundViewForButton.addSubview(buttonDetail)
        
        if (viewModel.categories.count > 0){ // Создание label с категориями
            var categoriesViewCount = 8
            var textCategories = ""
            if (viewModel.categories.count < 8) {
                categoriesViewCount = viewModel.categories.count
            }
            for i in 0...categoriesViewCount-1 {
                textCategories += viewModel.categories[i] + "\n"
            }
            let labelCategory = UILabel(frame: CGRect(x: self.backgroundViewForCategories.center.x-59, y: self.backgroundViewForCategories.center.y-169, width: 118, height: 142))
                labelCategory.numberOfLines = 0
                labelCategory.font = UIFont(name: "Helvetica" ,size: 13.0)
                labelCategory.text = String(textCategories)
                self.backgroundViewForCategories.addSubview(labelCategory)
        }

        viewModel.countRelay.subscribe { [self] (count) in // Уведоляем searchVC об изменении кол-ва товаров
            labelDetail.text = String(count.element!)
            NotificationCenter.default.post(name: Notification.Name("updateBag"),
                object: nil,
                userInfo:["id": productInfo.id , "count": count.element!, "reload": true, "name" : productInfo.title!, "producer" : productInfo.producer!])
            if (count.element! > 0) {
                buttonDetail.isHidden = true
                stepperDetail.isHidden = false
                labelDetail.isHidden = false
            } else {
                buttonDetail.isHidden = false
                stepperDetail.isHidden = true
                labelDetail.isHidden = true
            }
        }.disposed(by: DBag)

        buttonDetail.rx // Нажатие на кнопку
            .tap
            .subscribe {(_) in
                viewModel.countRelay.accept(1)
                stepperDetail.value = 1
            }.disposed(by: DBag)

        stepperDetail.rx // Нажатие на степпер
            .value
            .asObservable()
            .subscribe {(count) in
                viewModel.countRelay.accept(Int(count.element!))
            }.disposed(by: DBag)
    }
    
    private func configureProperties() {
        backgroundViewForButton.layer.backgroundColor = UIColor.systemBackground.cgColor
        backgroundViewForCategories.layer.backgroundColor = UIColor.systemBackground.cgColor
    }
}
