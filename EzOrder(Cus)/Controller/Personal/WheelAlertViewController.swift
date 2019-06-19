//
//  WheelAlertViewController.swift
//  EzOrder(Cus)
//
//  Created by Lee Chien Kuan on 2019/5/29.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit


class WheelAlertViewController: UIViewController {

    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var pointCountLabel: UILabel!
    
    var pointCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let outputString = "恭喜你獲得了\(point!)點！"
        outputLabel.text = outputString
        if let pointCount = pointCount{
            pointCountLabel.text = "剩餘\(pointCount)次轉盤機會"
        }
    }
    var point: Int!
    @IBAction func clickOK(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
