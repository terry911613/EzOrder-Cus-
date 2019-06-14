//
//  SearchMenuViewController.swift
//  EzOrder(Cus)
//
//  Created by 劉十六 on 2019/6/6.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase

class SearchMenuViewController: UIViewController {
    
    @IBOutlet weak var SearcMenuCollection: UICollectionView!
    @IBOutlet weak var searcMenuTableView: UITableView!
    
    var typeArray = [QueryDocumentSnapshot]()
    var foodArray = [QueryDocumentSnapshot]()
    var resID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        selectTypeMenu = all
//        allTypeMenu = [all, set, rice, noodle, soup, dessert]
    }
    
    func getFood(typeName: String){
        print("-------------")
        //   print(typeName)
        let db = Firestore.firestore()
        if let resID = resID{
            db.collection("res").document(resID).collection("foodType").document(typeName).collection("menu").order(by: "foodIndex", descending: false).addSnapshotListener { (food, error) in
                if let food = food{
                    if food.documents.isEmpty{
                        self.foodArray.removeAll()
                        self.searcMenuTableView.reloadData()
                        
                    }
                    else{
                        let documentChange = food.documentChanges[0]
                        if documentChange.type == .added {
                            self.foodArray = food.documents
                            print(self.foodArray.count)
                            self.searcMenuTableView.reloadData()
                            print("getFood Success")
                            print("-------------")
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "foodDetailSegue"{
            if let indexPath = searcMenuTableView.indexPathForSelectedRow{
                let food = foodArray[indexPath.row]
                print(food)
                let searchFoodDetailVC = segue.destination as! SearchFoodDetailViewController
                searchFoodDetailVC.food = food
            }
        }
    }

}
extension SearchMenuViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearcMenuCell", for: indexPath) as! SearcMenuCollectionViewCell
        let type = typeArray[indexPath.row]
        
        if let typeName = type.data()["typeName"] as? String,
            let typeImage = type.data()["typeImage"] as? String{
            cell.searcMenuName.text = typeName
            cell.searcMeneImageView.kf.setImage(with: URL(string: typeImage))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        selectTypeMenu = allTypeMenu[indexPath.row]
//        searcMenuTableView.reloadData()
        let cell = SearcMenuCollection.cellForItem(at: indexPath) as! SearcMenuCollectionViewCell
        cell.searcMeneImageView.alpha = 1
        let type = typeArray[indexPath.row]
        if let typeName = type.data()["typeName"] as? String{
            getFood(typeName: typeName)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = SearcMenuCollection.cellForItem(at: indexPath) as! SearcMenuCollectionViewCell
        cell.searcMeneImageView.alpha = 0.2
    }
}
extension SearchMenuViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodArray.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearcMenuTableCell", for: indexPath) as! SearcMenuTableViewCell
        
        let food = foodArray[indexPath.row]
        if let foodName = food.data()["foodName"] as? String,
            let foodImage = food.data()["foodImage"] as? String,
            let foodMoney = food.data()["foodPrice"] as? Int{
            
            cell.searcMenuTableName.text = foodName
            cell.searcMenuTabelImage.kf.setImage(with: URL(string: foodImage))
            cell.searcTableMenuMoney.text = "$\(foodMoney)"
            
        }
        
        if let foodTotalRate = food.data()["foodTotalRate"] as? Double,
        let foodRateCount = food.data()["foodRateCount"] as? Double {
            let foodRate = foodTotalRate/Double(foodRateCount)
            if foodRate < 2.75 {
                if foodRate < 0.25 {
                    cell.rateStarImageView.image = UIImage(named: "rate0")
                } else if foodRate < 0.75 {
                    cell.rateStarImageView.image = UIImage(named: "rate05")
                } else if foodRate < 1.25 {
                    cell.rateStarImageView.image = UIImage(named: "rate1")
                } else if foodRate < 1.75 {
                    cell.rateStarImageView.image = UIImage(named: "rate15")
                } else if foodRate < 2.25 {
                    cell.rateStarImageView.image = UIImage(named: "rate2")
                } else {
                    cell.rateStarImageView.image = UIImage(named: "rate25")
                }
            } else {
                if foodRate < 3.25 {
                    cell.rateStarImageView.image = UIImage(named: "rate3")
                } else if foodRate < 3.75 {
                    cell.rateStarImageView.image = UIImage(named: "rate35")
                } else if foodRate < 4.25 {
                    cell.rateStarImageView.image = UIImage(named: "rate4")
                } else if foodRate < 4.75 {
                    cell.rateStarImageView.image = UIImage(named: "rate45")
                } else {
                    cell.rateStarImageView.image = UIImage(named: "rate4")
                }
            }
        }
        
//        cell.searcMenuTableName.text =
//            selectTypeMenu[indexPath.row]
        return cell
    }
}
