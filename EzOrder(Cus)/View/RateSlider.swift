//
//  RateSlider.swift
//  EzOrder(Cus)
//
//  Created by Lee Chien Kuan on 2019/6/12.
//  Copyright © 2019 TerryLee. All rights reserved.
//
import UIKit
import Foundation

class RateSlider: UISlider {
    var resFoodVC: RateFoodViewController?
    var rateResVC: RateResViewController?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user touches the screen
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)

        if let resFoodVC = resFoodVC{
            let rate = location.x / (resFoodVC.rateImageView.frame.size.width/5)
            print(self.value)
            resFoodVC.rateSlider.value = Float(rate)
            resFoodVC.updateStar(value: Float(rate))
        }
        
        if let rateResVC = rateResVC{
            let rateRes = location.x / (rateResVC.rateView.frame.size.width/5)
            print(self.value)
            rateResVC.rateSlider.value = Float(rateRes)
            rateResVC.updateStar(value: Float(rateRes))
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        if let resFoodVC = resFoodVC{
            let rate = location.x / (resFoodVC.rateImageView.frame.size.width/5)
            print(self.value)
            resFoodVC.rateSlider.value = Float(rate)
            resFoodVC.updateStar(value: Float(rate))
        }
        
        if let rateResVC = rateResVC{
            let rate = location.x / (rateResVC.rateView.frame.size.width/5)
            print(self.value)
            rateResVC.rateSlider.value = Float(rate)
            rateResVC.updateStar(value: Float(rate))
        }
    }
}
