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

class ADViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var rankCollectionView: UICollectionView!
    @IBOutlet weak var adCollectionView: UICollectionView!
    @IBOutlet weak var adPageControl: UIPageControl!
    
    var okAdArray = [QueryDocumentSnapshot]()
    var recommendRes = [QueryDocumentSnapshot]()
    var imageIndexPath = 0
    var timerForAd = Timer()
    
    @objc func pushToStoreShowVC(notification: Notification) {
        self.tabBarController?.selectedIndex = 1
        if let searchNavController = self.tabBarController?.viewControllers?[1] as? UINavigationController, let resID = notification.userInfo?["resID"] as? String {
            let searchStoryboard: UIStoryboard = UIStoryboard(name: "Search", bundle: nil)
            let storeShowVC = searchStoryboard.instantiateViewController(withIdentifier: "storeShowVC") as! StoreShowViewController
            storeShowVC.resID = resID
            storeShowVC.enterFromFavorite = true
            self.tabBarController?.selectedIndex = 1
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("receiveAPNS"), object: nil)
            searchNavController.pushViewController(storeShowVC, animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(pushToStoreShowVC), name: NSNotification.Name("receiveAPNS"), object: nil)
        
        let db = Firestore.firestore()
        db.collection("res").whereField("status", isEqualTo: 1).addSnapshotListener { (res, error) in
            if let res = res{
                if res.documents.isEmpty == false{
                    self.recommendRes = res.documents
                    self.recommendRes.sort(by: { (left, right) -> Bool in
                        if let leftTotlaRate = left.data()["resTotalRate"] as? Double,
                            let leftRateCount = left.data()["resRateCount"] as? Double,
                            let rightTotalRate = right.data()["resTotalRate"] as? Double,
                            let rightRateCount = right.data()["resRateCount"] as? Double{
                            
                            if leftRateCount == 0 {
                                return 0 > rightTotalRate/rightRateCount
                            }
                            else if rightRateCount == 0{
                                return leftTotlaRate/leftRateCount > 0
                            }
                            return leftTotlaRate/leftRateCount > rightTotalRate/rightRateCount
                        }
                        else{
                            return false
                        }
                    })
                    if self.recommendRes.count > 5{
                        for i in 0...self.recommendRes.count - 1{
                            if i > 4{
                                self.recommendRes.remove(at: 5)
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        let db = Firestore.firestore()
        db.collection("manage").document("check").collection("AD").whereField("ADStatus", isEqualTo: 1).getDocuments { (AD, error) in
            self.okAdArray.removeAll()
            if let AD = AD{
                if AD.documents.isEmpty{
                    self.adCollectionView.reloadData()
                }
                else{
                    for ad in AD.documents{
                        if let startDate = ad.data()["startDate"] as? Timestamp,
                            let endDate = ad.data()["endDate"] as? Timestamp{
                            
                            if startDate.dateValue() < Date() && Date() < endDate.dateValue(){
                                self.okAdArray.append(ad)
                                self.adPageControl.numberOfPages = self.okAdArray.count
                                self.adCollectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        
//        self.adCollectionView.leftAnchor
        timerForAd = Timer.scheduledTimer(withTimeInterval: 4, repeats: true, block: { (Timer) in
            UIView.animate(withDuration: 1, animations: {
                var indexPath: IndexPath
                if self.imageIndexPath < self.okAdArray.count - 1 {
                    self.imageIndexPath += 1
                    indexPath = IndexPath(item: self.imageIndexPath, section: 0)
                    self.adCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                    self.setPageControll(tunning: 1)
                } else {
                    self.imageIndexPath = 0
                    indexPath = IndexPath(item: self.imageIndexPath, section: 0)
                    self.adCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                    self.setPageControll(tunning: (self.okAdArray.count - 1) * -1)
                }
            })
        })
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        timerForAd.invalidate()
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

extension ADViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == rankCollectionView {
            return recommendRes.count
        } else {
            return okAdArray.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == rankCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rankCell", for: indexPath) as! RankCollectionViewCell
            let recommend = recommendRes[indexPath.row]
            if let resImage = recommend.data()["resImage"] as? String,
                let resName = recommend.data()["resName"] as? String{
                cell.imgRank.kf.setImage(with: URL(string: resImage))
                cell.imgRank.layer.borderWidth = 2
                cell.imgRank.layer.borderColor = UIColor.gray.cgColor
                cell.lbRank.text = resName
            }
            if let resTotalRate = recommend.data()["resTotalRate"] as? Float,
                let resRateCount = recommend.data()["resRateCount"] as? Float{
                if resRateCount == 0{
                    updateStar(value: 0, image: cell.rateView)
                }
                else{
                    updateStar(value: resTotalRate/resRateCount, image: cell.rateView)
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "adCell", for: indexPath) as! AdCollectionViewCell
            
            let ad = okAdArray[indexPath.row]
            if let ADImage = ad.data()["ADImage"] as? String{
                cell.AdImageView.kf.setImage(with: URL(string: ADImage))
            }
            //            cell.AdImageView.image = UIImage(named: rankImgNames[indexPath.row])
            return cell
        }
    }



func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == adCollectionView {
        return  CGSize(width: collectionView.frame.width, height : collectionView.frame.height)

    }
    else {
        return CGSize(width: collectionView.frame.width/1.5, height : collectionView.frame.height)
    }
}


//func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//    return 40
//}

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedRes: DocumentSnapshot
        if collectionView === adCollectionView {
            selectedRes = (okAdArray[indexPath.row] as DocumentSnapshot)
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
}

