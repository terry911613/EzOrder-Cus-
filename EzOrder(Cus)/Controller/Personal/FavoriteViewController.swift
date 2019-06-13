//
//  FavoriteViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/6/4.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class FavoriteViewController: UIViewController {
    
    var favoriteResArray = [QueryDocumentSnapshot]()
    
    @IBOutlet weak var favoriteCollectionView: UICollectionView!
    var res: QueryDocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            db.collection("user").document(userID).collection("favoriteRes").getDocuments { (favoriteRes, error) in
                if let favoriteRes = favoriteRes{
                    if favoriteRes.documents.isEmpty{
                        self.favoriteResArray.removeAll()
                        self.favoriteCollectionView.reloadData()
                    }
                    else{
                        self.favoriteResArray = favoriteRes.documents
                        self.favoriteCollectionView.reloadData()
                    }
                }
            }
        }
    }
}

extension FavoriteViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteResArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath) as! FavoriteCollectionViewCell
        let favoriteRes = favoriteResArray[indexPath.row]
        if let favoriteResID = favoriteRes.data()["resID"] as? String{
            let db = Firestore.firestore()
            db.collection("res").document(favoriteResID).getDocument { (res, error) in
                if let resData = res?.data(){
                    if let resImage = resData["resImage"] as? String{
                        cell.favoriteImageView.kf.setImage(with: URL(string: resImage))
                    }
                }
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRes = favoriteResArray[indexPath.row] as DocumentSnapshot
        if let searchNavController = self.tabBarController?.viewControllers?[1] as? UINavigationController {
            var destinationVC: UIViewController?
            let viewControllers = searchNavController.children
            for viewController in viewControllers {
                if type(of: viewController) === StoreShowViewController.self {
                    destinationVC = viewController
                }
            }
            if let destinationVC = destinationVC as? StoreShowViewController {
                destinationVC.favRes = selectedRes
                destinationVC.enterFromFavorite = true
                destinationVC.beginningHandler = destinationVC.viewDidLoadProcess()
                self.tabBarController?.selectedIndex = 1
                searchNavController.popToViewController(destinationVC, animated: true)
            } else {
                searchNavController.popToRootViewController(animated: true)
                let searchStoryboard: UIStoryboard = UIStoryboard(name: "Search", bundle: nil)
                let storeShowVC = searchStoryboard.instantiateViewController(withIdentifier: "storeShowVC") as! StoreShowViewController
                storeShowVC.favRes = selectedRes
                storeShowVC.enterFromFavorite = true
                self.tabBarController?.selectedIndex = 1
                searchNavController.pushViewController(storeShowVC, animated: true)
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2, height: collectionView.frame.width/2)
    }
    
}
