//
//  ViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/15.
//  Copyright © 2019 TerryLee. All rights reserved.
//
// FACCCA
import UIKit
import Firebase
import Kingfisher

// 擴充navBar來做漸層
extension UINavigationBar {
    func addGradient(_ toAlpha: CGFloat, _ color: UIColor) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            color.withAlphaComponent(0.2).cgColor,
            color.withAlphaComponent(toAlpha).cgColor,
            color.withAlphaComponent(0.2).cgColor
        ]
        gradient.locations = [0, 0.5, 1]
        var frame = bounds
        frame.size.height += UIApplication.shared.statusBarFrame.size.height
        frame.origin.y -= UIApplication.shared.statusBarFrame.size.height
        gradient.frame = frame
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.insertSublayer(gradient, at: 1)
    }
}

class ADViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var rankCollectionView: UICollectionView!
    
    @IBOutlet weak var adCollectionView: UICollectionView!
    var rankImgNames = ["AD1", "AD2", "AD3", "AD4", "AD5"]
    var rankLabels = ["1.大特價\n買一送一\n要吃要快", "2.大特價\n買一送一\n要吃要快", "3.大特價\n買一送一\n要吃要快", "4.大特價\n買一送一\n要吃要快", "5.大特價\n買一送一\n要吃要快"]
    
    var adArray = [QueryDocumentSnapshot]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == rankCollectionView {
            return rankImgNames.count
        } else {
            return adArray.count
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == rankCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rankCell", for: indexPath) as! RankCollectionViewCell
            cell.imgRank.image = UIImage(named: rankImgNames[indexPath.row])
            cell.lbRank.text = rankLabels[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "adCell", for: indexPath) as! AdCollectionViewCell
            
            let ad = adArray[indexPath.row]
            if let ADImage = ad.data()["ADImage"] as? String{
                cell.AdImageView.kf.setImage(with: URL(string: ADImage))
            }
//            cell.AdImageView.image = UIImage(named: rankImgNames[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == adCollectionView {
            return CGSize(width: adCollectionView.frame.width, height: adCollectionView.frame.height)
        } else {
            return CGSize(width: collectionView.frame.width * 5/6, height: collectionView.frame.height)
        }
    }
    
    
    // 圖層漸層
    func createGradientLayer() {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.yellow.cgColor,UIColor.red.cgColor, UIColor.yellow.cgColor]
        gradientLayer.zPosition = -1
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        self.view.layer.addSublayer(gradientLayer)
    }
    
    @IBOutlet weak var adPageControl: UIPageControl!
    
    var imageIndexPath = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        db.collection("manage").document("check").collection("AD").whereField("ADStatus", isEqualTo: 1).getDocuments { (AD, error) in
            if let AD = AD{
                if AD.documents.isEmpty{
                    self.adArray.removeAll()
                    self.adCollectionView.reloadData()
//                    adPageControl.numberOfPages = self.adArray.count
                }
                else{
                    self.adArray = AD.documents
                    self.adCollectionView.reloadData()
                    self.adPageControl.numberOfPages = self.adArray.count
                }
            }
        }
        
        adCollectionView.delegate = self
        adCollectionView.showsVerticalScrollIndicator = false
        adCollectionView.showsHorizontalScrollIndicator = false
        adCollectionView.scrollsToTop = false

        // Do any additional setup after loading the view.
    }
    var timerForAd = Timer()
    override func viewWillAppear(_ animated: Bool) {
        timerForAd = Timer.scheduledTimer(withTimeInterval: 4, repeats: true, block: { (Timer) in
            UIView.animate(withDuration: 1, animations: {
                var indexPath: IndexPath
                if self.imageIndexPath < self.adArray.count - 1 {
                    self.imageIndexPath += 1
                    indexPath = IndexPath(item: self.imageIndexPath, section: 0)
                    self.adCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                    self.setPageControll(tunning: 1)
                } else {
                    self.imageIndexPath = 0
                    indexPath = IndexPath(item: self.imageIndexPath, section: 0)
                    self.adCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                    self.setPageControll(tunning: (self.adArray.count - 1) * -1)
                }
            })
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        timerForAd.invalidate()
    }
    
    func setPageControll(tunning: Int) {
        let page = Int(adCollectionView.contentOffset.x / adCollectionView.frame.size.width )
//        print(page)
//        print((adCollectionView as UIScrollView).contentOffset.x)
//        print(adCollectionView.frame.size.width * CGFloat(rankImgNames.count))
        adPageControl.currentPage = page + tunning
        imageIndexPath = page + tunning
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView === adCollectionView {
            setPageControll(tunning: 0)
            
        }
    }
    
}


