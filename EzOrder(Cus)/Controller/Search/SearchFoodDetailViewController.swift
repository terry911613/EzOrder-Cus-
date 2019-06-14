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
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var commentTableView: UITableView!
    
    var food: QueryDocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let food = food{
            if let foodImage = food.data()["foodImage"] as? String{
                
                foodImageView.kf.setImage(with: URL(string: foodImage))
            }
        }
    }
}

extension SearchFoodDetailViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return evaluation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell  = tableView.dequeueReusableCell(withIdentifier: "EvaluationCell", for: indexPath) as! EvaluationTableViewCell
        cell.evaluationTextView.text = evaluation[indexPath.row]
        return cell
    }
}
