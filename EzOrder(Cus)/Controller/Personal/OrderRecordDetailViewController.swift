//
//  OrderRecordDetailViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/6/12.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class OrderRecordDetailViewController: UIViewController {

    @IBOutlet weak var foodDetailTableView: UITableView!
    
    var foodArray = [QueryDocumentSnapshot]()
    var orderNo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email,
            let orderNo = orderNo{
            
            db.collection("user").document(userID).collection("order").document(orderNo).collection("orderFoodDetail").getDocuments { (food, error) in
                if let food = food{
                    if food.documents.isEmpty{
                        self.foodArray.removeAll()
                        self.foodDetailTableView.reloadData()
                    }
                    else{
                        self.foodArray = food.documents
                        self.foodDetailTableView.reloadData()
                    }
                }
            }
        }
    }
}

extension OrderRecordDetailViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderRecordDetailCell", for: indexPath) as! OrderRecordDetailTableViewCell
        let food = foodArray[indexPath.row]
        if let foodName = food.data()["foodName"] as? String,
            let foodImage = food.data()["foodImage"] as? String,
            let foodPrice = food.data()["foodPrice"] as? Int,
            let foodAmount = food.data()["foodAmount"] as? Int{
            
            cell.foodName.text = foodName
            cell.foodImage.kf.setImage(with: URL(string: foodImage))
            cell.foodPrice.text = "單價:$\(foodPrice)"
            cell.foodAmount.text = "數量:\(foodAmount)"
        }
        
        return cell
    }
    
    
}
