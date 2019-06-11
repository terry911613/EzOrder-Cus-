//
//  OrderRecordViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/6/4.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import ViewAnimator
import Kingfisher

class OrderRecordViewController: UIViewController {

    @IBOutlet weak var orderRecordTableView: UITableView!
    
//    var restaurantImage = ["AD1", "AD2", "AD3", "AD4", "AD5"]
//    var date = ["2019-01-01", "2019-02-02", "2019-03-03", "2019-04-04", "2019-05-05"]
//    var price = [1000, 2000, 3000, 4000, 5000]
//    var point = [10, 20, 30, 40, 50]
    
    var orderRecordArray = [QueryDocumentSnapshot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getOrderRecord()
    }
    
    func getOrderRecord(){
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            db.collection("user").document(userID).collection("order").whereField("payStatus", isEqualTo: 1).getDocuments { (orderRecord, error) in
                if let orderRecord = orderRecord{
                    if orderRecord.documents.isEmpty{
                        self.orderRecordArray.removeAll()
                        self.orderRecordTableView.reloadData()
                    }
                    else{
                        self.orderRecordArray = orderRecord.documents
                        self.animateProgressTableView()
                    }
                }
            }
        }
    }
    
    func animateProgressTableView(){
        let animations = [AnimationType.from(direction: .top, offset: 30.0)]
        orderRecordTableView.reloadData()
        UIView.animate(views: orderRecordTableView.visibleCells, animations: animations, completion: nil)
    }
}

extension OrderRecordViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderRecordArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderRecordCell", for: indexPath) as! OrderRecordTableViewCell
        
        let orderRecord = orderRecordArray[indexPath.row]
        let db = Firestore.firestore()
        
        if let resID = orderRecord.data()["resID"] as? String,
            let totalPrice = orderRecord.data()["totalPrice"] as? Int{
            
            cell.priceLabel.text = "價錢：$\(totalPrice)"
            
            db.collection("res").document(resID).getDocument { (res, error) in
                if let resData = res?.data(){
                    if let resImage = resData["resImage"] as? String{
                        
                        cell.restaurantImageView.kf.setImage(with: URL(string: resImage))
                    }
                }
            }
        }
        
//        cell.restaurantImageView.image = UIImage(named: restaurantImage[indexPath.row])
//        cell.dateLabel.text = "日期：" + date[indexPath.row]
//        cell.priceLabel.text = "價錢：" + String(price[indexPath.row])
//        cell.pointLabel.text = "點數：" + String(point[indexPath.row])
        return cell
    }
    
    
}
