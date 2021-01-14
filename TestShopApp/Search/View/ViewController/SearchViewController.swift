//
//  ViewController.swift
//  TestShopApp
//
//  Created by Vlad on 11.01.2021.
//

import UIKit
import RxCocoa
import RxSwift
import Concurrency
import QuartzCore

class SearchViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var cleanButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bagBarButton: UIBarButtonItem!
    
    @IBAction func bagButtonPressed(_ sender: UIBarButtonItem) { // Переход в корзину
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "Bag") as! BagViewController
        detailVC.productInfo = viewModel.bagArray
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    let messageFont = "HelveticaNeue"
    let toolBar = UIToolbar()
    let DBag = DisposeBag()
    let viewModel = SearchViewModel()
    let array = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObservers()
        keyboardSettings()
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        configureProperties()
        tableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
        
        let label = UILabel(frame: CGRect(x: self.view.center.x-150, y: self.view.center.y, width: 300, height: 100)) // Label для отображения состояния поиска
        label.textAlignment = .center
        label.font = UIFont(name: messageFont ,size: 20.0)
        self.view.addSubview(label)
        
        // Заполнение таблицы
        _ = viewModel.data.bind(to: tableView.rx.items(cellIdentifier: "ProductCell", cellType: ProductTableViewCell.self)) {
            (row,item,cell) in
            cell.initFromProduct(info: item, count: self.viewModel.getCountById(id: item.id) )
        }.disposed(by: DBag)
        
        _ = searchField.rx.text // Связываем TextField с поисков во viewModel
            .orEmpty
            .throttle(.milliseconds(600), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .do(onNext: { [self] (searchString) in
                if (searchString == "") {
                    cleanButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
                } else {
                    cleanButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
                }
                scrollToTop()
            })
            .bind(to: viewModel.searchText).disposed(by: DBag)
        
        viewModel.data // Отображение состояния поиска
            .subscribe { [self] (_) in
            if (viewModel.data.value.count == 0) {
                if (viewModel.isLoadingSmthNow.value == 0) && (viewModel.isLoadingSmthNow.isStarting == true) {
                    DispatchQueue.main.async {
                        activityIndicator.isHidden = true
                        activityIndicator.stopAnimating()
                        label.isHidden = false
                        label.text = "No Result"
                    }
                } else {
                    if Reachability.isConnectedToNetwork(){
                        DispatchQueue.main.async {
                            activityIndicator.isHidden = false
                            activityIndicator.startAnimating()
                            label.isHidden = false
                            label.text = "Loading ..."
                        }
                    }else{
                        DispatchQueue.main.async {
                            activityIndicator.isHidden = true
                            activityIndicator.stopAnimating()
                            label.isHidden = false
                            label.text = "No Connection"
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    label.isHidden = true
                    activityIndicator.isHidden = true
                    activityIndicator.stopAnimating()
                }
            }
        }.disposed(by: DBag)
        
        cleanButton.rx.tap.subscribe { [self] (_) in // Кнопка очистки поиска
            cleanButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
            searchField.text = ""
            viewModel.searchText.accept("")
            scrollToTop()
        }.disposed(by: DBag)
        
        tableView.rx // Данные об актуальном индексе видимых ячеек
            .willDisplayCell
            .asObservable()
            .subscribe { [self] ( _, indexPath) in
                let index = (tableView.indexPathsForVisibleRows![0][1])
                viewModel.visiblecellsindexpath.accept(index)
            }.disposed(by: DBag)
        
        tableView.rx // Переход на экран деталей
            .itemSelected
            .subscribe ( onNext: {
                [weak self] indexPath in
                if let cell = self?.tableView.cellForRow(at: indexPath) as? ProductTableViewCell{
                    cell.selectionStyle = .none
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let detailVC = storyboard.instantiateViewController(withIdentifier: "Details") as! DetailViewController
                    detailVC.productInfo = cell.productInfo
                    self?.navigationController?.pushViewController(detailVC, animated: true)
                }
            }).disposed(by: DBag)
        
        _ = viewModel.errorCondition // Подписываемся на ошибки с сервера
            .subscribe { [self] (value) in
                if (value.element! == true) {
                    ShowAlert()
                }
            }.disposed(by: DBag)
    }
    
    private func scrollToTop() { // Поднимаемся в верх списка при новом запросе поиска
        if !tableView.visibleCells.isEmpty {
            let indexPath = IndexPath(row: 0 , section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    private func keyboardSettings() { // Кнопка для скрытия клавиатуры
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonPressed))
        let spaceFill = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolBar.setItems([spaceFill,doneButton], animated: true)
        searchField.inputAccessoryView = toolBar
    }
    
    
    private func configureProperties() {
        
        let title = "Search"
        let radius = CGFloat(6)
        let placeholder = "Search by product name"
        let color = UIColor.systemBlue
        self.tableView.separatorStyle = .none
        tableView.bounces = true
        navigationItem.title = title
        navigationController?.navigationBar.prefersLargeTitles = true
        bagBarButton.tintColor = color
        cleanButton.imageView?.tintColor = UIColor.white
        backgroundView.layer.cornerRadius = radius
        backgroundView.layer.backgroundColor = color.cgColor
        searchField.placeholder = placeholder
    }
    
    func ShowAlert(){ // Окно вспывает на ошибки при взаимодействии с сервером
        let alert = UIAlertController(title: "Houston, we have a problem...", message: "We have a small problem on the server. We'll fix it soon", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "I'll come back later", style: .cancel, handler: { (action) in
            UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
        }))
        present(alert, animated: true)
    }
    
    @objc func doneButtonPressed() {
        self.view.endEditing(true)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(someMethod),
            name: Notification.Name("updateBag"),
            object: nil)
    }

    @objc func someMethod(_ notification: Notification) {
        let id = notification.userInfo?["id"] as! Int
        let count = notification.userInfo?["count"] as! Int
        let name = notification.userInfo?["name"] as!String
        let producer = notification.userInfo?["producer"] as! String
        let reload = notification.userInfo?["reload"] as! Bool
        self.viewModel.sendInfoInBag(data: productInBag(id: id, count: count, name: name, producer: producer))
        if reload { tableView.reloadData() }
    }
}
