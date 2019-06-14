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
    var tableNo: Int?
    
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser?.email

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let totalPrice = totalPrice{
            totalPriceLabel.text = "總共$\(totalPrice)"
        }
        
        sortOrderArray()
    }
    
    func sortOrderArray(){
        
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
        
        let alert = UIAlertController(title: "確定送單？", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "確定", style: .default) { (ok) in
            self.upload()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func upload(){
        
        let timeStamp = Date().timeIntervalSince1970
        if let userID = userID, let resID = resID, let tableNo = tableNo, let totalPrice = totalPrice{
            let orderNo = String(timeStamp) + userID
            for i in 0...orderArray.count-1{
                let order = orderArray[i]
                let amount = amountArray[i]
                if let foodName = order.data()["foodName"] as? String,
                    let foodImage = order.data()["foodImage"] as? String,
                    let foodPrice = order.data()["foodPrice"] as? Int,
                    let typeName = order.data()["typeName"] as? String{
                    let orderFoodData: [String: Any] = ["typeName": typeName,
                                                        "foodName": foodName,
                                                        "foodImage": foodImage,
                                                        "foodPrice": foodPrice,
                                                        "foodAmount": amount,
                                                        "orderNo": orderNo,
                                                        "userID": userID,
                                                        "resID": resID,
                                                        "tableNo": tableNo,
                                                        "orderFoodStatus": 0]
                    db.collection("user").document(userID).collection("order").document(orderNo).collection("orderFoodDetail").document(foodName).setData(orderFoodData)
                    db.collection("res").document(resID).collection("order").document(orderNo).collection("orderFoodDetail").document(foodName).setData(orderFoodData)
                    
                    let orderData: [String: Any] = ["date": Date(),
                                                    "orderNo": orderNo,
                                                    "userID": userID,
                                                    "resID": resID,
                                                    "tableNo": tableNo,
                                                    "totalPrice": totalPrice,
                                                    "payStatus": 0]
                    db.collection("user").document(userID).collection("order").document(orderNo).setData(orderData)
                    db.collection("res").document(resID).collection("order").document(orderNo).setData(orderData)
                    
                }
            }
            let serviceData: [String: Any] = ["serviceBellStatus": 0]
            db.collection("user").document(userID).collection("order").document(orderNo).collection("serviceBellStatus").document("isServiceBell").setData(serviceData)
            db.collection("res").document(resID).collection("order").document(orderNo).collection("serviceBellStatus").document("isServiceBell").setData(serviceData)
            
            let completeData: [String: Any] = ["orderCompleteStatus": 0]
            db.collection("user").document(userID).collection("order").document(orderNo).collection("orderCompleteStatus").document("isOrderComplete").setData(completeData)
            db.collection("res").document(resID).collection("order").document(orderNo).collection("orderCompleteStatus").document("isOrderComplete").setData(completeData)
            
            performSegue(withIdentifier: "unwindSegueToProgress", sender: self)
        }
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
            let foodMoney = order.data()["foodPrice"] as? Int{
            
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
