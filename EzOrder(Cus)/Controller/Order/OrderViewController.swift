//
//  OrderViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/25.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class OrderViewController: UIViewController {

    @IBOutlet weak var typeCollectionView: UICollectionView!
    @IBOutlet weak var orderTableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var tableLabel: UILabel!
    
    var type = ["全部", "套餐", "麵", "飯", "湯", "甜點"]
    
    
    var selectTypeMenu = [String]()
    var all = ["滷肉飯", "雞肉飯", "排骨飯", "雞腿飯", "香腸飯", "乾麵", "湯麵", "義大利麵"]
    var set = ["滷肉飯套餐", "雞肉飯套餐", "排骨飯套餐", "雞腿飯套餐", "香腸飯套餐", "乾麵套餐", "湯麵套餐", "義大利麵套餐"]
    var rice = ["滷肉飯", "雞肉飯", "排骨飯", "雞腿飯", "香腸飯"]
    var noodle = ["乾麵", "湯麵", "義大利麵"]
    var soup = ["蛤蠣湯", "貢丸湯"]
    var dessert = ["蛋糕", "紅豆湯"]
    var allTypeMenu = [[String]]()
    
    
    var table = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableLabel.text = table + "桌"
        selectTypeMenu = all
        allTypeMenu = [all, set, rice, noodle, soup, dessert]
    }
//    var totals = [Int]()
//    var finalPrice = 0
}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectTypeMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderTableViewCell
        cell.name.text = selectTypeMenu[indexPath.row]
        cell.stepper.tag = indexPath.row
        
        cell.foodPrice = 50
        var amount = 0
//        var _totalPrice = 0
//        var totalPrice: Int {
//            set {
//                _totalPrice += newValue - totalPrice
//                totals[indexPath.row] = totalPrice
//            }
//            get {
//                return _totalPrice
//            }
//        }
        cell.callBackStepper = { value in
//            amount += value
            cell.price.text = "$\(Int(value * 50))"
            cell.count.text = "數量:\(Int(value))"
            
//            totalPrice = Int(value * 50)
//            self.totalPriceLabel.text = "總共: $\(totalPrice)"
        }
        return cell
    }
}

extension OrderViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return type.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "typeCell", for: indexPath) as! TypeCollectionViewCell
        cell.typeLabel.text = type[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TypeCollectionViewCell
        cell.backView.backgroundColor = UIColor(red: 255/255, green: 66/255, blue: 150/255, alpha: 1)
        selectTypeMenu = allTypeMenu[indexPath.row]
        orderTableView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TypeCollectionViewCell
        cell.backView.backgroundColor = UIColor(red: 255/255, green: 162/255, blue: 195/255, alpha: 1)
    }
}
