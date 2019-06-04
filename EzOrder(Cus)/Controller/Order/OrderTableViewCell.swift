//
//  OrderTableViewCell.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/25.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var orderImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var plusBtn: UIButton!
    var callBackStepper:((_ value:Double)->())?
    var callBackCount: ((_ clickPlus: Bool, _ countAmount: Int)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if countAmount <= 0 {
            minusBtn.isEnabled = false
        }
    }
    var countAmount = 0
    @IBAction func clickMinus(_ sender: Any) {
        countAmount -= 1
        callBackCount?(false, countAmount)
        if countAmount <= 0 {
            minusBtn.isEnabled = false
        }
    }
    
    @IBAction func clickPlus(_ sender: Any) {
        countAmount += 1
        callBackCount?(true, countAmount)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func stepper(_ sender: UIStepper) {
        callBackStepper?(1)
    }
}
