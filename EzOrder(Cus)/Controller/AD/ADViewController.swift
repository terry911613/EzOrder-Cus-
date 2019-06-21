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
    var rankImgNames = ["涓豆腐logo", "涓豆腐logo", "涓豆腐logo", "涓豆腐logo", "涓豆腐logo"]
    var rankLabels = ["1.大特價\n買一送一\n要吃要快", "2.大特價\n買一送一\n要吃要快", "3.大特價\n買一送一\n要吃要快", "4.大特價\n買一送一\n要吃要快", "5.大特價\n買一送一\n要吃要快"]
    //    lazy var cardLayout: FlatCardCollectionViewLayout = {
    //        let layout = FlatCardCollectionViewLayout()
    //        layout.itemSize = CGSize(width: 247, height: 143)
    //        return layout
    //    }()
    var adArray = [QueryDocumentSnapshot]()
    var recommendRes = [QueryDocumentSnapshot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        db.collection("manage").document("check").collection("AD").whereField("ADStatus", isEqualTo: 1).getDocuments { (AD, error) in
            if let AD = AD{
                if AD.documents.isEmpty{
                    self.adArray.removeAll()
                    self.adCollectionView.reloadData()
                }
                else{
                    self.adArray = AD.documents
                    self.adCollectionView.reloadData()
                    self.adPageControl.numberOfPages = self.adArray.count
                }
            }
        }
        
        db.collection("res").whereField("status", isEqualTo: 1).getDocuments { (res, error) in
            if let res = res{
                if res.documents.isEmpty == false{
                    self.recommendRes = res.documents
                    self.recommendRes.sort(by: { (left, right) -> Bool in
                        if let leftTotlaRate = left.data()["resTotalRate"] as? Double,
                            let leftRateCount = left.data()["resRateCount"] as? Double,
                            let rightTotalRate = right.data()["resTotalRate"] as? Double,
                            let rightRateCount = right.data()["resRateCount"] as? Double{
                            
                            return leftTotlaRate/leftRateCount > rightTotalRate/rightRateCount
                        }
                        else{
                            return false
                        }
                    })
                    if self.recommendRes.count > 5{
                        for i in 0...self.recommendRes.count{
                            if i > 5{
                                self.recommendRes.remove(at: i)
                            }
                        }
                    }
                    self.rankCollectionView.reloadData()
                }
            }
        }
        
        adCollectionView.delegate = self
        adCollectionView.showsVerticalScrollIndicator = false
        adCollectionView.showsHorizontalScrollIndicator = false
        adCollectionView.scrollsToTop = false
        
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == rankCollectionView {
            return recommendRes.count
        } else {
            return adArray.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == rankCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rankCell", for: indexPath) as! RankCollectionViewCell
            let recommend = recommendRes[indexPath.row]
            if let resImage = recommend.data()["resImage"] as? String,
                let resName = recommend.data()["resName"] as? String{
                cell.imgRank.kf.setImage(with: URL(string: resImage))
                cell.lbRank.text = resName
            }
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
            return  CGSize(width: collectionView.frame.width * 0.9,height : collectionView.frame.height * 0.9 )
            
        } else {
            return CGSize(width: collectionView.frame.width , height : collectionView.frame.height)
        }
    }
    //
    //    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedRes: DocumentSnapshot
        if collectionView === adCollectionView {
            selectedRes = (adArray[indexPath.row] as DocumentSnapshot)
        } else {
            selectedRes = (recommendRes[indexPath.row] as DocumentSnapshot)
        }
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
                destinationVC.backgroundScrollView.setContentOffset(CGPoint.zero, animated: true)
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
    
    var timerForAd = Timer()
    override func viewWillAppear(_ animated: Bool) {
        self.adCollectionView.leftAnchor
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



