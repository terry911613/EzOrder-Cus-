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
    let animator = SearchAnimation()
    let animatorPop = SearcAnimationPop()
    var textStoreArray = [String]()
    var searchBool = false
    var searchbool = false
    var searcArray = [SearcArray]()
    var searcArrays = [SearcArray]()
    var selectRes: QueryDocumentSnapshot?
    var resID : String?
    var viewHeight: CGFloat?
    override func viewDidLoad() {
        self.searcArrays = self.searcArray
        navigationController?.delegate = self
        super.viewDidLoad()
        
        navigationController?.delegate = self
//        addKeyboardObserver()
        storeTableView.keyboardDismissMode = .onDrag
        getRes()
    }
    
    func getRes(){
        let db = Firestore.firestore()
        db.collection("res").whereField("status", isEqualTo: 1).addSnapshotListener { (res, error) in
            if let res = res{
                if res.documents.isEmpty{
                    self.resArray.removeAll()
                    self.storeTableView.reloadData()
                }
                else{
                    self.resArray = res.documents
                    self.animateStoreTableView()
                    
                    for res in res.documents{
                        if let resName = res.data()["resName"] as? String,let resImage = res.data()["resImage"] as? String,let resTotalRate = res.data()["resTotalRate"] as? Float,
                            let resRateCount = res.data()["resRateCount"] as? Float,let resid = res.data()["resID"] as? String {
                            self.searcArray.append(SearcArray(name: resName, image: resImage, resTotalRate: resTotalRate, resCount: resRateCount,ID: resid))
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
        storeShowVC.DocumentID = resID
        if searchBool == true   {
            storeShowVC.searcbool = true
        }
        else {
            storeShowVC.searcbool = false
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

extension SearchViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBool {
            
            return  searcArrays.count
        }
        else if searchbool == false{
                return resArray.count
        } else {
            return searcArray.count
        
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearcStoreTableViewCell
        if searchBool {
            cell.StoreName.text = searcArrays[indexPath.row].name
            cell.StoreImage.kf.setImage(with: URL(string: searcArrays[indexPath.row].image))

            if searcArrays[indexPath.row].resTotalRate == 0{
                updateStar(value: 0, image: cell.rateView)
            }else{
             updateStar(value: searcArrays[indexPath.row].resTotalRate/searcArrays[indexPath.row].resCount, image: cell.rateView)
            }
                        }
        else  if searchbool == false {
                    if searchbool == false {
                                    let res = resArray[indexPath.row]
                                    if let resName = res.data()["resName"] as? String,
                                        let resImage = res.data()["resImage"] as? String{
            
                                        cell.StoreName.text = resName
                                        cell.StoreImage.kf.setImage(with: URL(string: resImage))
                                    }
                                    if let resTotalRate = res.data()["resTotalRate"] as? Float,
                                        let resRateCount = res.data()["resRateCount"] as? Float{
            
                                        if resRateCount == 0{
                                            updateStar(value: 0, image: cell.rateView)
                                        }
                                        else{
                                            updateStar(value: resTotalRate/resRateCount, image: cell.rateView)
                                        }
            
                                    }
                                    else{
                                        cell.rateView.isHidden = true
                                    }
                                        }

        }else{
            cell.StoreName.text = searcArray[indexPath.row].name
            cell.StoreImage.kf.setImage(with: URL(string: searcArray[indexPath.row].image))
            
            if searcArray[indexPath.row].resTotalRate == 0{
                updateStar(value: 0, image: cell.rateView)
            }
            else{
                updateStar(value: searcArray[indexPath.row].resTotalRate/searcArray[indexPath.row].resCount, image: cell.rateView)}
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchBool == true {
        let resid = searcArrays[indexPath.row].ID
        resID = resid
        }
        let res = resArray[indexPath.row]
        selectRes = res
        performSegue(withIdentifier: "resDetailSegue", sender: self)
    }
}

extension SearchViewController: UISearchBarDelegate{
//    let searchString = searchController.searchBar.text!
//    searchSongs = songs.filter { (name) -> Bool in
//    return name.contains(searchString)
//    }


    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        searcArrays = searcArray.filter{
//            (name) -> Bool in
//
//            return name.name.contains(searchText)
//        }
        
    searcArrays = searcArray.filter({$0.name.prefix(searchText.count) == searchText})

        searchBool = true
        searchbool = true
        storeTableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBool = false
        
        searchBar.text = ""
        storeTableView.reloadData()
        self.view.endEditing(true)
    }
}

extension SearchViewController : UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        if operation == .push {
        animator.duration = 0.3
            return animator

        }
        else if operation == .pop {
        
        animatorPop.duration = 0.3
            
        }
        return animatorPop
        
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
