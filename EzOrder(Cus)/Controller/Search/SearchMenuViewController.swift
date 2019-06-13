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
    
    var type = ["全部", "套餐", "麵", "飯", "湯", "甜點"]
    var selectTypeMenu = [String]()
    var all = ["滷肉飯", "雞肉飯", "排骨飯", "雞腿飯", "香腸飯", "乾麵", "湯麵", "義大利麵"]
    var set = ["滷肉飯套餐", "雞肉飯套餐", "排骨飯套餐", "雞腿飯套餐", "香腸飯套餐", "乾麵套餐", "湯麵套餐", "義大利麵套餐"]
    var rice = ["滷肉飯", "雞肉飯", "排骨飯", "雞腿飯", "香腸飯"]
    var noodle = ["乾麵", "湯麵", "義大利麵"]
    var soup = ["蛤蠣湯", "貢丸湯"]
    var dessert = ["蛋糕", "紅豆湯"]
    var allTypeMenu = [[String]]()
    var Money = ["10,20,30,40,50,60"]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        selectTypeMenu = all
        allTypeMenu = [all, set, rice, noodle, soup, dessert]
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
        
        let type = typeArray[indexPath.row]
        if let typeName = type.data()["typeName"] as? String{
            getFood(typeName: typeName)
        }
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
        
//        cell.searcMenuTableName.text =
//            selectTypeMenu[indexPath.row]
        return cell
    }
}
