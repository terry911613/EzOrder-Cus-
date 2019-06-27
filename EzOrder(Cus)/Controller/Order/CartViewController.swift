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
    @IBOutlet weak var tableLabel: UILabel!
    
    var totalPrice: Int?
    var orderDic = [QueryDocumentSnapshot: Int]()
    var orderArray = [QueryDocumentSnapshot]()
    var amountArray = [Int]()
    var resID: String?
    var tableNo: Int?
    var orderNo: String?
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let totalPrice = totalPrice,
            let tableNo = tableNo{
            totalPriceLabel.text = "總共$\(totalPrice)"
            tableLabel.text = "\(tableNo)桌"
        }
        
        sortOrderArray()
        
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateFormat = "yyyy年M月d日"
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
        
        if orderDic.isEmpty{
            let alert = UIAlertController(title: "尚未加入任何餐點", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "確定送單？", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default) { (ok) in
                self.upload()
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func upload() {
        
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            // 加點模式
            if let orderNo = orderNo,
                let resID = resID,
                let tableNo = tableNo,
                let totalPrice = totalPrice {
                
                db.collection("user").document(userID).collection("order").document(orderNo).getDocument { (documentSnapshot, error) in
                    if var orderData = documentSnapshot?.data() {
                        let oldTotalPrice = orderData["totalPrice"] as! Int
                        let oldExtraOrderCount = orderData["extraOrderCount"] as! Int
                        let newTotalPrice = oldTotalPrice + totalPrice
                        let newExtraOrderCount = oldExtraOrderCount + 1
                        orderData["totalPrice"] = newTotalPrice
                        orderData["extraOrderCount"] = newExtraOrderCount
                        
                        let extraOrderCountStr = String(newExtraOrderCount)
                        
                        
                        db.collection("user").document(userID).collection("order").document(orderNo).updateData(orderData)
                        db.collection("res").document(resID).collection("order").document(orderNo).updateData(orderData)
                        
                        for i in 0...self.orderArray.count-1 {
                            let order = self.orderArray[i]
                            let amount = self.amountArray[i]
                            if let foodName = order.data()["foodName"] as? String,
                                let foodImage = order.data()["foodImage"] as? String,
                                let foodPrice = order.data()["foodPrice"] as? Int,
                                let typeDocumentID = order.data()["typeDocumentID"] as? String,
                                let foodDocumentID = order.data()["foodDocumentID"] as? String{
                                
                                let documentID = foodDocumentID + extraOrderCountStr
                                
                                let orderFoodData: [String: Any] = ["documentID": documentID,
                                                                    "foodDocumentID": foodDocumentID,
                                                                    "typeDocumentID": typeDocumentID,
                                                                    "foodName": foodName,
                                                                    "foodImage": foodImage,
                                                                    "foodPrice": foodPrice,
                                                                    "foodAmount": amount,
                                                                    "orderNo": orderNo,
                                                                    "userID": userID,
                                                                    "resID": resID,
                                                                    "tableNo": tableNo,
                                                                    "orderFoodStatus": 0]
                                
                                
                                
                                db.collection("user").document(userID).collection("order").document(orderNo).collection("orderFoodDetail").document(documentID).setData(orderFoodData)
                                db.collection("res").document(resID).collection("order").document(orderNo).collection("orderFoodDetail").document(documentID).setData(orderFoodData)
                                
                                let completeData: [String: Any] = ["orderCompleteStatus": 0]
                                db.collection("user").document(userID).collection("order").document(orderNo).collection("orderCompleteStatus").document("isOrderComplete").setData(completeData)
                                db.collection("res").document(resID).collection("order").document(orderNo).collection("orderCompleteStatus").document("isOrderComplete").setData(completeData)
                                
                                
                                //  存點餐次數，做圖表
                                let dateString = self.formatter.string(from: Date())
                                db.collection("res").document(resID).collection("foodType").document(typeDocumentID).collection("menu").document(foodDocumentID).collection("foodAmount").document(dateString).getDocument { (foodAmount, error) in
                                    
                                    if let foodAmountData = foodAmount?.data(){
                                        if let foodAmount = foodAmountData["foodAmount"] as? Int{
                                            
                                            let foodAmountData: [String: Any] = ["foodAmount": foodAmount + amount,
                                                                                 "date": Date()]
                                            db.collection("res").document(resID).collection("foodType").document(typeDocumentID).collection("menu").document(foodDocumentID).collection("foodAmount").document(dateString).updateData(foodAmountData)
                                            
                                        }
                                        else{
                                            let foodAmountData: [String: Any] = ["foodName": foodName,
                                                                                 "dateString": dateString,
                                                                                 "foodAmount": amount,
                                                                                 "date": Date()]
                                            db.collection("res").document(resID).collection("foodType").document(typeDocumentID).collection("menu").document(foodDocumentID).collection("foodAmount").document(dateString).setData(foodAmountData)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                performSegue(withIdentifier: "unwindSegueToProgress", sender: self)
                self.navigationController?.popToRootViewController(animated: false)
                
            } else { // 全新點單
                if let resID = resID,
                    let tableNo = tableNo,
                    let totalPrice = totalPrice{
                    let orderNo = String(Date().timeIntervalSince1970) + userID
                    for i in 0...orderArray.count-1{
                        let order = orderArray[i]
                        let amount = amountArray[i]
                        if let foodName = order.data()["foodName"] as? String,
                            let foodImage = order.data()["foodImage"] as? String,
                            let foodPrice = order.data()["foodPrice"] as? Int,
                            let typeDocumentID = order.data()["typeDocumentID"] as? String,
                            let foodDocumentID = order.data()["foodDocumentID"] as? String{
                            let orderFoodData: [String: Any] = ["documentID": foodDocumentID,
                                                                "foodDocumentID": foodDocumentID,
                                                                "typeDocumentID": typeDocumentID,
                                                                "foodName": foodName,
                                                                "foodImage": foodImage,
                                                                "foodPrice": foodPrice,
                                                                "foodAmount": amount,
                                                                "orderNo": orderNo,
                                                                "userID": userID,
                                                                "resID": resID,
                                                                "tableNo": tableNo,
                                                                "orderFoodStatus": 0]
                            db.collection("user").document(userID).collection("order").document(orderNo).collection("orderFoodDetail").document(foodDocumentID).setData(orderFoodData)
                            db.collection("res").document(resID).collection("order").document(orderNo).collection("orderFoodDetail").document(foodDocumentID).setData(orderFoodData)
                            
                            
                            let dateString = formatter.string(from: Date())
                            
                            let orderData: [String: Any] = ["date": Date(),
                                                            "dateString": dateString,
                                                            "orderNo": orderNo,
                                                            "userID": userID,
                                                            "resID": resID,
                                                            "tableNo": tableNo,
                                                            "totalPrice": totalPrice,
                                                            "payStatus": 0,
                                                            "extraOrderCount": 0]
                            db.collection("user").document(userID).collection("order").document(orderNo).setData(orderData)
                            db.collection("res").document(resID).collection("order").document(orderNo).setData(orderData)
                            
                            
                            //  存點餐次數，做圖表
                            db.collection("res").document(resID).collection("foodType").document(typeDocumentID).collection("menu").document(foodDocumentID).collection("foodAmount").document(dateString).getDocument { (foodAmount, error) in
                                
                                if let foodAmountData = foodAmount?.data(){
                                    if let foodAmount = foodAmountData["foodAmount"] as? Int{
                                        print(444)
                                        
                                        let foodAmountData: [String: Any] = ["foodAmount": foodAmount + amount,
                                                                             "date": Date()]
                                        db.collection("res").document(resID).collection("foodType").document(typeDocumentID).collection("menu").document(foodDocumentID).collection("foodAmount").document(dateString).updateData(foodAmountData)
                                        
                                    }
                                }
                                else{
                                    print(123)
                                    let foodAmountData: [String: Any] = ["foodName": foodName,
                                                                         "dateString": dateString,
                                                                         "foodAmount": amount,
                                                                         "date": Date()]
                                    db.collection("res").document(resID).collection("foodType").document(typeDocumentID).collection("menu").document(foodDocumentID).collection("foodAmount").document(dateString).setData(foodAmountData)
                                }
                            }
                        }
                    }
                    let serviceData: [String: Any] = ["serviceBellStatus": 0]
                    db.collection("user").document(userID).collection("order").document(orderNo).collection("serviceBellStatus").document("isServiceBell").setData(serviceData)
                    db.collection("res").document(resID).collection("order").document(orderNo).collection("serviceBellStatus").document("isServiceBell").setData(serviceData)
                    
                    let completeData: [String: Any] = ["orderCompleteStatus": 0]
                    db.collection("user").document(userID).collection("order").document(orderNo).collection("orderCompleteStatus").document("isOrderComplete").setData(completeData)
                    db.collection("res").document(resID).collection("order").document(orderNo).collection("orderCompleteStatus").document("isOrderComplete").setData(completeData)
                    
                    performSegue(withIdentifier: "unwindSegueToProgress", sender: self)
                    self.navigationController?.popToRootViewController(animated: false)
                }
                
            }
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
