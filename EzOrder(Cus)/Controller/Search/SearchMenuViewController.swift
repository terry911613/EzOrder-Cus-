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
    


}
extension SearchMenuViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return type.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearcMenuCell", for: indexPath) as! SearcMenuCollectionViewCell
        cell.searcMenuName.text = type[indexPath.row]
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectTypeMenu = allTypeMenu[indexPath.row]
        searcMenuTableView.reloadData()
    }
    
    
}
extension SearchMenuViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectTypeMenu.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearcMenuTableCell", for: indexPath) as! SearcMenuTableViewCell
        cell.searcMenuTableName.text =
            selectTypeMenu[indexPath.row]
            return cell
    }
    
    
    
}
