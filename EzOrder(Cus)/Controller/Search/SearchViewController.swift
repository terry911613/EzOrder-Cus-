//
//  SearchViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/15.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import ViewAnimator

class SearchViewController: UIViewController {
    
    @IBOutlet weak var storeSearch: UISearchBar!
    @IBOutlet weak var storeTableView: UITableView!
    
    var resArray = [QueryDocumentSnapshot]()
    
    var textStoreArray = [String]()
    var searchBool = false
    var searchChange = [String]()
//    var selectRes: QueryDocumentSnapshot?
    var selectRes: DocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRes()
    }
    
    func getRes(){
        let db = Firestore.firestore()
        db.collection("res").getDocuments { (res, error) in
            if let res = res{
                if res.documents.isEmpty{
                    self.resArray.removeAll()
                    self.storeTableView.reloadData()
                }
                else{
                    self.resArray = res.documents
                    self.animateStoreTableView()
                    
                    for res in res.documents{
                        if let resName = res.data()["resName"] as? String{
                            self.textStoreArray.append(resName)
                        }
                    }
                }
            }
        }
    }
    
    func animateStoreTableView(){
        let animations = [AnimationType.from(direction: .top, offset: 30.0)]
        storeTableView.reloadData()
        UIView.animate(views: storeTableView.visibleCells, animations: animations, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let storeShowVC = segue.destination as! StoreShowViewController
        storeShowVC.res = selectRes
//        storeSearch.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SearchViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBool {
            return  searchChange.count
        }
        else {
            return resArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearcStoreTableViewCell
        if searchBool {
            cell.StoreName.text = searchChange[indexPath.row]
        }
        else {
            let res = resArray[indexPath.row]
            if let resName = res.data()["resName"] as? String{
                cell.StoreName.text = resName
            }
            print(2)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let res = resArray[indexPath.row] as! DocumentSnapshot
        selectRes = res
        performSegue(withIdentifier: "resDetailSegue", sender: self)
    }
}

extension SearchViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchChange = textStoreArray.filter({$0.prefix(searchText.count) == searchText})
        searchBool = true
        storeTableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBool = false
        searchBar.text = ""
        storeTableView.reloadData()
    }
}
