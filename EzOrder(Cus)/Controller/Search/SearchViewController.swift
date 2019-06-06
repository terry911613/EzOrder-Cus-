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
    let textStoreTableView = ["1","2","3","4","5","6","7","8","9","10"]
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
        let Cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if searchBool {
            Cell?.textLabel?.text = searchChange[indexPath.row]
            print(1)
        }
        else {
            Cell?.textLabel?.text =  textStoreTableView[indexPath.row]
            print(2)
        }
       
        return Cell!
    }
    override func didReceiveMemoryWarning() {
        self.didReceiveMemoryWarning()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchChange = textStoreTableView.filter({$0.prefix(searchText.count) == searchText})
                searchBool = true
                StoreTableView.reloadData()

        
        
    }
    
    
    
}
