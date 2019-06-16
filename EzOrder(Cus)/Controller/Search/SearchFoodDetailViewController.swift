//
//  searcEvaluationViewController.swift
//  EzOrder(Cus)
//
//  Created by 劉十六 on 2019/6/7.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class SearchFoodDetailViewController: UIViewController {
    
    var evaluation = ["1","2","3","4","5"]
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var foodPriceLabel: UILabel!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodDetailLabel: UITextView!
    @IBOutlet weak var foodTotalRateImageView: UIImageView!
    @IBOutlet weak var commentTableView: UITableView!
    
    var food: QueryDocumentSnapshot?
    var resID: String?
    var avgRate: Float?
    var foodRateCount: Float?
    var foodCommentArray = [QueryDocumentSnapshot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let foodRateCount = foodRateCount{
            if foodRateCount == 0{
                foodTotalRateImageView.isHidden = true
            }
            else{
                if let avgRate = avgRate{
                    updateStar(value: avgRate, image: foodTotalRateImageView)
                }
            }
        }
       
        
        if let food = food{
            print(food.data()["foodImage"] as? String)
            print(food.data()["foodName"] as? String)
            print(food.data()["foodPrice"] as? Int)
            print(food.data()["foodDetail"] as? String)
            if let foodImage = food.data()["foodImage"] as? String,
                let foodName = food.data()["foodName"] as? String,
                let foodPrice = food.data()["foodPrice"] as? Int,
                let foodDetail = food.data()["foodDetail"] as? String,
                let typeDocumentID = food.data()["typeDocumentID"] as? String,
            let foodDocumentID = food.data()["foodDocumentID"] as? String{
                
                foodImageView.kf.setImage(with: URL(string: foodImage))
                foodNameLabel.text = "菜名：\(foodName)"
                foodPriceLabel.text = "價格：$\(foodPrice)"
                foodDetailLabel.text = "\(foodDetail)"
                
                let db = Firestore.firestore()
                if let resID = resID{
                    db.collection("res").document(resID).collection("foodType").document(typeDocumentID).collection("menu").document(foodDocumentID).collection("foodComment").getDocuments { (foodComment, error) in
                        if let foodComment = foodComment{
                            if foodComment.documents.isEmpty{
                                self.foodCommentArray.removeAll()
                                self.commentTableView.reloadData()
                            }
                            else{
                                self.foodCommentArray = foodComment.documents
                                self.commentTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    func updateStar(value: Float, image: UIImageView) {
        let rate = value
        if rate < 2.75 {
            if rate < 0.25 {
                image.image = UIImage(named: "rate0")
            } else if rate < 0.75 {
                image.image = UIImage(named: "rate05")
            } else if rate < 1.25 {
                image.image = UIImage(named: "rate1")
            } else if rate < 1.75 {
                image.image = UIImage(named: "rate15")
            } else if rate < 2.25 {
                image.image = UIImage(named: "rate2")
            } else {
                image.image = UIImage(named: "rate25")
            }
        } else {
            if rate < 3.25 {
                image.image = UIImage(named: "rate3")
            } else if rate < 3.75 {
                image.image = UIImage(named: "rate35")
            } else if rate < 4.25 {
                image.image = UIImage(named: "rate4")
            } else if rate < 4.75 {
                image.image = UIImage(named: "rate45")
            } else {
                image.image = UIImage(named: "rate5")
            }
        }
    }
}

extension SearchFoodDetailViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodCommentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "EvaluationCell", for: indexPath) as! FoodDetailTableViewCell
        
        let comment = foodCommentArray[indexPath.row]
        
        if let foodComment = comment.data()["foodComment"] as? String,
            let foodRate = comment.data()["foodRate"] as? Float,
            let userID = comment.data()["userID"] as? String{
            
            cell.evaluationTextView.text = foodComment
            updateStar(value: foodRate, image: cell.rateImageView)
            
            let db = Firestore.firestore()
            db.collection("user").document(userID).getDocument { (user, error) in
                if let userData = user?.data(),
                    let userImage = userData["userImage"] as? String{
                    cell.evaluationImageView.kf.setImage(with: URL(string: userImage))
                }
            }
        }
        
        return cell
    }
}
