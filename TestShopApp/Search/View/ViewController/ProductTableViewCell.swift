//
//  ProductTableViewCell.swift
//  TestShopApp
//
//  Created by Vlad on 11.01.2021.
//

import UIKit
import RxSwift
import RxCocoa

class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundRounded: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var producerLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var buttonBackground: UIView!
    
    private let CornerRadius = CGFloat(10)
    private let buttonStepperRadius = CGFloat(6)
    private let noDataString = "No category"
    private let buttonLabelStepperColor = UIColor.systemBlue
    private let allBackgroundColor = UIColor.systemBackground
    private let allTextColor = UIColor.white
    let DBag = DisposeBag()
    var productInfo = Product()
    
    var countInBag = BehaviorRelay<Int>(value: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureProperties()
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        let label = UILabel(frame: CGRect(x: self.buttonBackground.center.x-105, y: self.buttonBackground.center.y-130, width: 30, height: 30)) // Label для отображения выбранного количесвта товаров
            label.textAlignment = .center
            label.textColor = allTextColor
            label.backgroundColor = buttonLabelStepperColor
            label.layer.masksToBounds = true
            label.text = String(productInfo.countInBag)
            label.layer.cornerRadius = 15
            self.buttonBackground.addSubview(label)
        
        let stepper = UIStepper(frame: CGRect(x: self.buttonBackground.center.x-169, y: self.buttonBackground.center.y-12, width: 94, height: 32)) // Степпер для изменения выбранного количсевта товаров
            stepper.backgroundColor = buttonLabelStepperColor
            stepper.setDecrementImage(stepper.decrementImage(for: .normal), for: .normal)
            stepper.setIncrementImage(stepper.incrementImage(for: .normal), for: .normal)
            stepper.tintColor = allTextColor
            stepper.layer.cornerRadius = buttonStepperRadius
            stepper.maximumValue = 20
            stepper.minimumValue = 0
            self.buttonBackground.addSubview(stepper)
            getShadow(view: stepper, opacity: 0.9, radius: 3)
            stepper.isHidden = true
        
        let button = UIButton(frame: CGRect(x: self.buttonBackground.center.x-169, y: self.buttonBackground.center.y-12, width: 94, height: 32)) // Кнопка для выбора товара
            button.backgroundColor = buttonLabelStepperColor
            button.layer.cornerRadius = buttonStepperRadius
            button.setImage(UIImage(systemName: "bag.badge.plus"), for: .normal)
            button.tintColor = allBackgroundColor
            self.buttonBackground.addSubview(button)
            getShadow(view: button, opacity: 0.9, radius: 3)
            label.isHidden = true
        
        countInBag.subscribe { [self] (count) in // Изменение данных о выбранном количестве товаров
            label.text = String(count.element!)
            stepper.value = Double(count.element!)
            productInfo.countInBag = count.element!
            
            NotificationCenter.default.post(name: Notification.Name("updateBag"), // Уведомление в searchVC
                object: nil,
                userInfo:["id": productInfo.id , "count": count.element!, "reload": false, "name" : productInfo.title!, "producer" : productInfo.producer!])
            
            if (count.element! > 0) {
                button.isHidden = true
                stepper.isHidden = false
                label.isHidden = false
                backgroundRounded.layer.borderWidth = 2
                backgroundRounded.layer.borderColor = buttonLabelStepperColor.cgColor
                backgroundRounded.layer.shadowColor = buttonLabelStepperColor.cgColor
            } else {
                button.isHidden = false
                stepper.isHidden = true
                label.isHidden = true
                backgroundRounded.layer.borderWidth = 0
                backgroundRounded.layer.shadowColor = UIColor.systemGray.cgColor
            }
        }.disposed(by: DBag)
        
        button.rx
            .tap
            .subscribe { [self] (_) in
                countInBag.accept(1)
                stepper.value = 1
            }.disposed(by: DBag)
        
        stepper.rx
            .value
            .asObservable()
            .subscribe { [self] (count) in
                countInBag.accept(Int(count.element!))
            }.disposed(by: DBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initFromProduct(info : Product, count : Int) { // Инициализация через данные с сервера
        productInfo = info
        if (info.image != nil){
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
        if (info.categories!.count == 0){
            categoryLabel.text = noDataString
        } else {
            categoryLabel.text = info.categories![0].title
        }
        productImage.image = info.image
        titleLabel.text = info.title
        producerLabel.text = info.producer
        priceLabel.text = String(info.price ?? 0) + " ₽"
        productInfo.countInBag = count
        countInBag.accept(productInfo.countInBag)
    }
    
    private func configureProperties() {
        backgroundRounded.translatesAutoresizingMaskIntoConstraints = false
        backgroundRounded.layer.cornerRadius = CornerRadius
        buttonBackground.layer.backgroundColor = allBackgroundColor.cgColor
        backgroundRounded.layer.backgroundColor = allBackgroundColor.cgColor
        getShadow(view: backgroundRounded, opacity: 0.8, radius: 4)
    }
    
    private func getShadow(view: UIView, opacity : Float, radius : CGFloat){
        view.layer.shadowColor = UIColor.systemGray.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowOpacity = opacity
        view.layer.shadowRadius = radius
    }
}
