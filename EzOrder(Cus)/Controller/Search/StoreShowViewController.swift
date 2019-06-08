//
//  StoreShowViewController.swift
//  EzOrder(Cus)
//
//  Created by 劉十六 on 2019/6/6.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import MapKit

class StoreShowViewController: UIViewController{
    
    @IBOutlet weak var showClassificationCollection: UICollectionView!
    @IBOutlet weak var showStoreImageVIew: UIImageView!
    @IBOutlet weak var showStoreName: UILabel!
    @IBOutlet weak var showStoreAddress: UILabel!
    @IBOutlet weak var showStoreOpenTime: UILabel!
    @IBOutlet weak var showStorePhone: UILabel!
    @IBOutlet weak var showLikeImageVIew: UIImageView!
    @IBOutlet weak var linkBottonImage: UIButton!
    @IBOutlet weak var textUmageview: UIImageView!
    @IBOutlet var textimage2: [UIImageView]!
    @IBOutlet weak var showAddressButton: UIButton!
    var clickButton = true
    let geoCoder = CLGeocoder()
    
    
    var lise = ["1","2","3","4","5"]
    override func viewDidLoad() {
        geoCoder.geocodeAddressString("新竹縣竹北市光明一路93號市"){
            (placemarks,error) in
            if error != nil {
                let placemark = placemarks![0] as CLPlacemark?
                print(placemark?.location?.coordinate)
                
                return
            }
            if placemarks != nil  && (placemarks?.count)! > 0 {
                let placemark = placemarks![0] as CLPlacemark?
                print(placemark?.location?.coordinate)
            }
        }
        super.viewDidLoad()
    }
    @IBAction func limkButtonAction(_ sender: Any) {
        let image = UIImage(named: "donut")
        let imageViews = UIImageView(image: image!)
        imageViews.frame = CGRect(x: 303, y: 294, width: 30, height: 30)
        view.addSubview(imageViews)
        textimage2.insert(imageViews, at: 0)
         clickButton = !clickButton
        if clickButton == false{
        linkBottonImage.setImage(UIImage(named: "donut"), for: .normal)
            UIView.animate(withDuration: 1.5 , delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.textimage2[0].frame = CGRect(x:126 , y: 149, width: self.textimage2[0].frame.size.width * 2, height: self.textimage2[0].frame.size.height * 2)
                imageViews.alpha = 0.7
            }, completion: {Result -> Void in
                imageViews.removeFromSuperview()
                
            })
                    }
        if clickButton == true {
            linkBottonImage.setImage(UIImage(named: "link"), for: .normal)
            imageViews.isHidden = true
        }
        
        
    }
}



extension StoreShowViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lise.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MuneCell", for: indexPath) as! StoreShowCollectionViewCell
      //  cell.showStoresImageView.image = UIImage(named: lise[indexPath.row])
        cell.showClassificationName.text = lise[indexPath.row]
        return cell
    }
    
    
}

