//
//  ViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/15.
//  Copyright © 2019 TerryLee. All rights reserved.
//
// FACCCA
import UIKit

class ADViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
    }
    
    @IBOutlet weak var scrollviewAd: UIScrollView!
    @IBOutlet weak var pgcontrolAd: UIPageControl!
    @IBOutlet weak var imgAd1: UIImageView!
    @IBOutlet weak var imgAd2: UIImageView!
    @IBOutlet weak var imgAd3: UIImageView!
    @IBOutlet weak var imgAd4: UIImageView!
    @IBOutlet weak var imgAd5: UIImageView!
    
    @IBOutlet weak var collectviewRank: UICollectionView!
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
        
        // Do any additional setup after loading the view.
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //通过scrollView内容的偏移计算当前显示的是第几页
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        //设置pageController的当前页
        pgcontrolAd.currentPage = page
    }
    

}

