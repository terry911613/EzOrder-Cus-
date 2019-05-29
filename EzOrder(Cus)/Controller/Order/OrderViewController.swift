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
    
    var type = ["全部", "套餐", "麵", "飯", "湯", "甜點"]
    var name = ["滷肉飯", "雞肉飯", "排骨飯", "雞腿飯", "香腸飯"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return name.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderTableViewCell
        cell.name.text = name[indexPath.row]
        cell.stepper.tag = indexPath.row
        var totalPrice = 0
        cell.callBackStepper = { value in
            cell.price.text = "$\(Int(value * 50))"
            cell.count.text = "數量:\(Int(value))"
//            totalPrice += Int(value * 50)
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
}
