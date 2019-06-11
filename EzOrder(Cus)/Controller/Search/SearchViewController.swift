//
//  SearchViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/15.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate  {
    
    @IBOutlet weak var StoreSearch: UISearchBar!
    @IBOutlet weak var StoreTableView: UITableView!
    let textStoreTableView = ["鼎泰豐","鼎王","藏壽司","夏慕尼","彼得潘小吃","黃家牛肉麵","三顧茅廬","小木屋鬆餅","小點心","冠有滷肉飯"]
    var searchBool = false
    var searchChange = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBool {
          return  searchChange.count
        }
        else {
        return textStoreTableView.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearcStoreTableViewCell
        if searchBool {
            Cell.StoreName.text = searchChange[indexPath.row]
                  }
        else {
            Cell.StoreName.text = textStoreTableView[indexPath.row]
            print(2)
        }
       
        return Cell
    }
    override func didReceiveMemoryWarning() {
        self.didReceiveMemoryWarning()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchChange = textStoreTableView.filter({$0.prefix(searchText.count) == searchText})
                searchBool = true
                StoreTableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBool = false
        searchBar.text = ""
        StoreTableView.reloadData()
    }

    
    
}
