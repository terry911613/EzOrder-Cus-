//
//  FavoriteViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/6/4.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController {
    
    var favoriteResaurant = [String]()
    
    @IBOutlet weak var favoriteCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoriteResaurant = ["AD1", "AD2", "AD3", "AD4", "AD5"]
    }
}

extension FavoriteViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteResaurant.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath) as! FavoriteCollectionViewCell
        cell.favoriteImageView.image = UIImage(named: favoriteResaurant[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2, height: collectionView.frame.width/2)
    }
    
}
