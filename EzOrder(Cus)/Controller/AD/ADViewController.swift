//
//  ViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/15.
//  Copyright © 2019 TerryLee. All rights reserved.
//
// FACCCA
import UIKit

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

class ADViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var rankCollectionView: UICollectionView!
    
    var rankImgNames = ["AD1", "AD2", "AD3", "AD4", "AD5"]
    var rankLabels = ["1.大特價\n買一送一\n要吃要快", "2.大特價\n買一送一\n要吃要快", "3.大特價\n買一送一\n要吃要快", "4.大特價\n買一送一\n要吃要快", "5.大特價\n買一送一\n要吃要快"]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rankImgNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rankCell", for: indexPath) as! RankCollectionViewCell
        cell.imgRank.image = UIImage(named: rankImgNames[indexPath.row])
        cell.lbRank.text = rankLabels[indexPath.row]
        return cell
    }
    
    @IBOutlet weak var scrollviewAd: UIScrollView!
    @IBOutlet weak var pgcontrolAd: UIPageControl!
    @IBOutlet weak var imgAd1: UIImageView!
    @IBOutlet weak var imgAd2: UIImageView!
    @IBOutlet weak var imgAd3: UIImageView!
    @IBOutlet weak var imgAd4: UIImageView!
    @IBOutlet weak var imgAd5: UIImageView!
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgAd1.image = UIImage(named: "AD1")
        imgAd2.image = UIImage(named: "AD2")
        imgAd3.image = UIImage(named: "AD3")
        imgAd4.image = UIImage(named: "AD4")
        imgAd5.image = UIImage(named: "AD5")

        scrollviewAd.delegate = self
        scrollviewAd.showsVerticalScrollIndicator = false
        scrollviewAd.showsHorizontalScrollIndicator = false
        scrollviewAd.scrollsToTop = false
        
        var timerForAd = Timer()
        timerForAd = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (Timer) in
            UIView.animate(withDuration: 0.3, animations: {
                if self.scrollviewAd.contentOffset.x == self.scrollviewAd.frame.size.width * 4 {
                    self.scrollviewAd.contentOffset.x = 0
                    self.setPageControll()
                } else {
                    self.scrollviewAd.contentOffset.x += self.scrollviewAd.frame.size.width
                    self.setPageControll()
                }
            })
        })
        // Do any additional setup after loading the view.
    }
    
    func setPageControll() {
        let page = Int(scrollviewAd.contentOffset.x / scrollviewAd.frame.size.width)
        pgcontrolAd.currentPage = page
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView === scrollviewAd {
            setPageControll()
        }
    }
    
}
