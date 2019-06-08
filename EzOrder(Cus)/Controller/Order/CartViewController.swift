//
//  ShoppingCartViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/28.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class CartViewController: UIViewController {
    
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    var totalPrice: Int?
    var orderDic = [QueryDocumentSnapshot: Int]()
    var orderArray = [QueryDocumentSnapshot]()
    var amountArray = [Int]()
    var resID: String?
    
    let db = Firestore.firestore()
    let userId = Auth.auth().currentUser?.email

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let totalPrice = totalPrice{
            totalPriceLabel.text = "總共$\(totalPrice)"
        }
        
        for (order, _) in orderDic{
            orderArray.append(order)
        }
        orderArray.sort { (left, right) -> Bool in
            if let leftTypeIndex = left.data()["typeIndex"] as? Int, let rightTypeIndex = right.data()["typeIndex"] as? Int{
                return leftTypeIndex <= rightTypeIndex
            }
            else{
                return false
            }
        }
        orderArray.sort { (left, right) -> Bool in
            if let leftTypeIndex = left.data()["foodIndex"] as? Int, let rightTypeIndex = right.data()["foodIndex"] as? Int{
                return leftTypeIndex <= rightTypeIndex
            }
            else{
                return false
            }
        }
    }
    
    @IBAction func okButton(_ sender: UIButton) {
        
        for i in 0...orderArray.count-1{
            let order = orderArray[i]
            let amount = amountArray[i]
            
            if let foodName = order.data()["foodName"] as? String,
                let foodImage = order.data()["foodImage"] as? String,
                let foodMoney = order.data()["foodMoney"] as? Int{
                let data: [String: Any] = ["orderNo": typeIndex,
                                           "foodName": foodName,
                                           "foodImage": downloadURL.absoluteString,
                                           "foodMoney": foodMoney,
                                           "foodIndex": foodIndex,
                                           "foodDetail": self.foodDetailTextfield.text ?? ""]
                db.collection("testUser").document("order").collection("detail").document("\(Date())")
            }
        }
        performSegue(withIdentifier: "unwindSegueToProgress", sender: self)
    }
}

extension CartViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath) as! CartTableViewCell
        let order = orderArray[indexPath.row]
        if let foodName = order.data()["foodName"] as? String,
            let foodImage = order.data()["foodImage"] as? String,
            let foodMoney = order.data()["foodMoney"] as? Int{
            
            cell.foodNameLabel.text = foodName
            cell.foodImageView.kf.setImage(with: URL(string: foodImage))
            cell.foodPriceLabel.text = "$\(foodMoney)"
            
            for (orderKey, amount) in orderDic{
                if order == orderKey{
                    cell.amountLabel.text = "數量：\(amount)"
                    amountArray.append(amount)
                    break
                }
            }
        }
        
        return cell
    }
    
}
