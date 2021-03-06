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
    var resID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.setNavigationBarHidden(false, animated: false)
        
        let db = Firestore.firestore()
        
        if let resID = resID{
            db.collection("res").document(resID).getDocument { (res, error) in
                if let resData = res?.data(){
                    if let resName = resData["resName"] as? String{
                        self.navigationItem.title = "\(resName)" 
                    }
                }
            }
        }
        
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dishRateVC = segue.destination as? RateFoodViewController {
            if let indexPath = foodDetailTableView.indexPathForSelectedRow,
                let orderNo = orderNo{
                let food = foodArray[indexPath.row]
                if let foodDocumentID = food.data()["foodDocumentID"] as? String,
                    let resID = food.data()["resID"] as? String,
                    let typeDocumentID = food.data()["typeDocumentID"] as? String,
                    let foodName = food.data()["foodName"] as? String,
                let documentID = food.data()["documentID"] as? String{
                    dishRateVC.foodDocumentID = foodDocumentID
                    dishRateVC.resID = resID
                    dishRateVC.typeDocumentID = typeDocumentID
                    dishRateVC.foodName = foodName
                    dishRateVC.documentID = documentID
                }
                dishRateVC.orderNo = orderNo
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
            
            cell.foodNameLabel.text = foodName
            cell.foodImageView.kf.setImage(with: URL(string: foodImage))
            cell.foodPriceLabel.text = "單價:$\(foodPrice)"
            cell.foodAmountLabel.text = "數量:\(foodAmount)"
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "rateDishSegue", sender: self)
    }
}
