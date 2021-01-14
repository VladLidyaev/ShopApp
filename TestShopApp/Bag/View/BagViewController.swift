//
//  BagViewController.swift
//  TestShopApp
//
//  Created by Vlad on 14.01.2021.
//

import UIKit
import RxCocoa
import RxSwift

class BagViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var productInfo : [productInBag]!
    var DBag = DisposeBag()
    
    var viewModel = BagViewModel(info: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = BagViewModel(info: productInfo)

        _ = viewModel.data.bind(to: tableView.rx.items(cellIdentifier: "bagProductCell")) { // Заполнение таблицы
            (row,item,cell) in
            cell.textLabel!.text = item.name
            cell.detailTextLabel!.text = item.producer
            cell.imageView!.image = item.image
        }.disposed(by: DBag)
        
        // Label для пустой корзины
        let labelCenter = UILabel(frame: CGRect(x: self.view.center.x-100, y: self.view.center.y-50, width: 200, height: 100))
            labelCenter.numberOfLines = 0
            labelCenter.font = UIFont(name: "HelveticaNeue" ,size: 20.0)
            labelCenter.text = String("Your bag is empty")
            labelCenter.textAlignment = .center
            self.view.addSubview(labelCenter)
        
        _ = viewModel.data.subscribe(onNext: { [self] (info) in // Изменение внутренних границ в иаблице и заголовка в зависимости от наличия товаров в корзине
            if info.count == 0 {
                self.navigationItem.title = "Bag"
                labelCenter.isHidden = false
                tableView.separatorStyle = .none
            } else {
                self.navigationItem.title = "Total in bag: \(viewModel.allCount)"
                labelCenter.isHidden = true
                tableView.separatorStyle = .singleLine
            }
        }).disposed(by: DBag)
        
        tableView.allowsSelection = false
    }
}
