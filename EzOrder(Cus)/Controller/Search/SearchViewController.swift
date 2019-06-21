//
//  SearchViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/15.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
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
    var viewHeight: CGFloat?
    override func viewDidLoad() {
        super.viewDidLoad()
//        addKeyboardObserver()
        storeTableView.keyboardDismissMode = .onDrag
        getRes()
    }
    
    func getRes(){
        let db = Firestore.firestore()
        db.collection("res").whereField("status", isEqualTo: 1).getDocuments { (res, error) in
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
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
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
            if let resName = res.data()["resName"] as? String,
                let resImage = res.data()["resImage"] as? String{
                cell.StoreName.text = resName
                cell.StoreImage.kf.setImage(with: URL(string: resImage))
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
        self.view.endEditing(true)
    }
}

//extension SearchViewController {
//    func addKeyboardObserver() {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
    
//    @objc func keyboardWillShow(notification: Notification) {
//        // 能取得鍵盤高度就讓view上移鍵盤高度，否則上移view的1/3高度
//        viewHeight = view.frame.height
//        let scrolledPosition = storeTableView.contentOffset.y
//        let scrolledRow = (scrolledPosition / storeTableView.rowHeight).rounded()
//        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardRect = keyboardFrame.cgRectValue
////            let keyboardHeight = keyboardRect.height
////            let keyboardWidth = keyboardRect.width
////            let viewX = view.frame.origin.x
////            let viewY = view.frame.origin.y
//
//
//            view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: keyboardRect.origin.y)
//            storeTableView.scrollToRow(at: IndexPath(row: Int(scrolledRow), section: 0), at: .top, animated: true)
//        } else {
//            view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 2 / 3)
//            storeTableView.scrollToRow(at: IndexPath(row: Int(scrolledRow), section: 0), at: .top, animated: true)
//        }
//    }
//
//    @objc func keyboardWillHide(notification: Notification) {
//        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: viewHeight!)
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(true)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//}
