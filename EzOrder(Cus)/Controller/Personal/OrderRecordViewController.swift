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
    
    var orderRecordArray = [QueryDocumentSnapshot]()
    var selectOrderNo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let orderRecordDetailVC = segue.destination as! OrderRecordDetailViewController
        if let selectOrderNo = selectOrderNo{
            print(selectOrderNo)
            orderRecordDetailVC.orderNo = selectOrderNo
        }
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderRecord = orderRecordArray[indexPath.row]
        if let orderNo = orderRecord.data()["orderNo"] as? String{
            selectOrderNo = orderNo
            performSegue(withIdentifier: "foodDetailSegue", sender: self)
        }
    }
}
