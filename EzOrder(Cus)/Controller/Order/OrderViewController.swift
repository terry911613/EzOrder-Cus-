//
//  OrderViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/25.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import ViewAnimator
import Kingfisher

class OrderViewController: UIViewController {

    @IBOutlet weak var typeCollectionView: UICollectionView!
    @IBOutlet weak var orderTableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var tableLabel: UILabel!
    
    var totalPrice = 0
    
    var tableNo: Int?
    var resID: String?
    
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser?.email
    var typeArray = [QueryDocumentSnapshot]()
    var foodArray = [QueryDocumentSnapshot]()
    var orderDic = [QueryDocumentSnapshot: Int]()
    var isFoodDiffrient = false
    var orderAmounts = [[Int]]()
    var selectTypeIndex = 0
    
    var foodCount = [Int]()
    var orderAmounts = [[Int]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tableNo = tableNo{
            tableLabel.text = "\(tableNo)桌"
        }
        getType()
    }
    func getType(){
        if let resID = resID{
            db.collection("res").document(resID).collection("foodType").order(by: "index", descending: true).getDocuments { (type, error) in
                if let type = type{
                    if type.documentChanges.isEmpty{
                        self.typeArray.removeAll()
                        self.typeCollectionView.reloadData()
                    }
                    else{
                        
                        self.typeArray = type.documents
                        self.animateTypeCollectionView()
                        for i in 1...self.typeArray.count {
                            self.orderAmounts.append([])
                        }
                        
                        var typeIndex = 0
                        for type in type.documents{
                            if let typeName = type.data()["typeName"] as? String{
                                self.db.collection("res").document(resID).collection("foodType").document(typeName).collection("menu").getDocuments { (food, error) in
                                    
                                    print("--------")
                                    print(food?.documents.count)
                                    print("--------")
                                    
//                                    if let foodCount = food?.documents.count {
//                                        for i in 0...foodCount {
//                                            self.orderAmounts[typeIndex].append(0)
//                                        }
//                                    }
//                                    typeIndex += 1
                                    print("-------")
                                    print(food?.documents.count)
                                    print(food?.documents)
                                    if let foodCount = food?.documents.count {
                                        if foodCount != 0 {
                                            for i in 1...foodCount {
                                                self.orderAmounts[typeIndex].append(0)
                                            }
                                            
                                        }
                                        typeIndex += 1
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func getFood(typeName: String){
        print("-------------")
        print(typeName)
        if let resID = resID{
            db.collection("res").document(resID).collection("foodType").document(typeName).collection("menu").getDocuments { (food, error) in
                if let food = food{
                    if food.documents.isEmpty{
                        self.foodArray.removeAll()
                        self.orderTableView.reloadData()
                    }
                    else{
                        let documentChange = food.documentChanges[0]
                        if documentChange.type == .added {
                            self.foodArray = food.documents
                            print(self.foodArray.count)
                            self.animateOrderTableView()
                            print("getFood Success")
                            print("-------------")
                        }
                    }
                }
            }
        }
    }
    
    func animateTypeCollectionView(){
        typeCollectionView.reloadData()
        let animations = [AnimationType.from(direction: .right, offset: 30.0)]
        typeCollectionView.performBatchUpdates({
            UIView.animate(views: self.typeCollectionView.orderedVisibleCells,
                           animations: animations, completion: nil)
        }, completion: nil)
    }
    func animateOrderTableView(){
        let animations = [AnimationType.from(direction: .top, offset: 30.0)]
        orderTableView.reloadData()
        UIView.animate(views: orderTableView.visibleCells, animations: animations, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cartSegue"{
            let cartVC = segue.destination as! CartViewController
            cartVC.totalPrice = totalPrice
            cartVC.orderDic = orderDic
            if let resID = resID, let tableNo = tableNo{
                cartVC.resID = resID
                cartVC.tableNo = tableNo
            }
        }
    }
}
extension OrderViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "typeCell", for: indexPath) as! TypeCollectionViewCell
        let type = typeArray[indexPath.row]
        if let typeName = type.data()["typeName"] as? String,
            let typeImage = type.data()["typeImage"] as? String{
            cell.typeLabel.text = typeName
            cell.typeImage.kf.setImage(with: URL(string: typeImage))
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TypeCollectionViewCell
        cell.backView.backgroundColor = UIColor(red: 255/255, green: 66/255, blue: 150/255, alpha: 1)
        
        if let type = typeArray[indexPath.row].data()["typeName"] as? String{
            getFood(typeName: type)
        }
        selectTypeIndex = indexPath.row
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TypeCollectionViewCell
        cell.backView.backgroundColor = UIColor(red: 255/255, green: 162/255, blue: 195/255, alpha: 1)
    }
}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderTableViewCell
        let food = foodArray[indexPath.row]
        
//        cell.name.text = selectTypeMenu[indexPath.row]
//        cell.stepper.tag = indexPath.row
        
        if let foodName = food.data()["foodName"] as? String,
            let foodImage = food.data()["foodImage"] as? String,
            let foodMoney = food.data()["foodPrice"] as? Int{
            print("orderAmounts: ",orderAmounts)
            print("selectTypeIndex", selectTypeIndex)
            var thisFoodAmount = self.orderAmounts[self.selectTypeIndex][indexPath.row]
            cell.countAmount = thisFoodAmount
            cell.count.text = "數量:\(String(thisFoodAmount))"
            
            cell.name.text = foodName
            cell.orderImageView.kf.setImage(with: URL(string: foodImage))
            cell.price.text = "$\(foodMoney)"
            
            cell.callBackCount = { clickPlus, countAmount in
                cell.count.text = "數量:\(countAmount)"
                if clickPlus == true {
                    self.orderDic[food] = countAmount
                    self.totalPrice += foodMoney
                    self.orderAmounts[self.selectTypeIndex][indexPath.row] += 1
                } else {
                    self.orderDic[food] = countAmount
                    self.totalPrice -= foodMoney
                    self.orderAmounts[self.selectTypeIndex][indexPath.row] -= 1
                }
                self.totalPriceLabel.text = "總共: $\(self.totalPrice)"
            }
        }
        //        cell.callBackStepper = { value in
        //            cell.price.text = "$\(Int(value * 50))"
        //            cell.count.text = "數量:\(Int(value))"
        //            totalPrice += Int(value * 50)
        //            self.totalPriceLabel.text = "總共: $\(totalPrice)"
        //        }
        return cell
    }
}
