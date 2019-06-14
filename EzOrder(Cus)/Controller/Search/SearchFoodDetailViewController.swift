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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let food = food{
            print(food.data()["foodImage"] as? String)
            print(food.data()["foodName"] as? String)
            print(food.data()["foodPrice"] as? Int)
            print(food.data()["foodDetail"] as? String)
            if let foodImage = food.data()["foodImage"] as? String,
                let foodName = food.data()["foodName"] as? String,
                let foodPrice = food.data()["foodPrice"] as? Int,
                let foodDetail = food.data()["foodDetail"] as? String{
                
                foodImageView.kf.setImage(with: URL(string: foodImage))
                foodNameLabel.text = "菜名：\(foodName)"
                foodPriceLabel.text = "價格：$\(foodPrice)"
                foodDetailLabel.text = "\(foodDetail)"
            }
        }
    }
}

extension SearchFoodDetailViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return evaluation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell  = tableView.dequeueReusableCell(withIdentifier: "EvaluationCell", for: indexPath) as! FoodDetailTableViewCell
        cell.evaluationTextView.text = evaluation[indexPath.row]
        return cell
    }
}
