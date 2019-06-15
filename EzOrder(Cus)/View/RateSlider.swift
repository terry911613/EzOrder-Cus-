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
    var parentVC: RateDishViewController!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user touches the screen
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)

        let rate = location.x / (parentVC.rateImageView.frame.size.width/5)
        print(self.value)
        parentVC.rateSlider.value = Float(rate)
        parentVC.updateStar(value: Float(rate))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        let rate = location.x / (parentVC.rateImageView.frame.size.width/5)
        print(self.value)
        parentVC.rateSlider.value = Float(rate)
        parentVC.updateStar(value: Float(rate))
    }
}
