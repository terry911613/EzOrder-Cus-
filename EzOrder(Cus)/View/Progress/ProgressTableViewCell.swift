//
//  ProgressTableViewCell.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/6/8.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class ProgressTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var foodPriceLabel: UILabel!
    @IBOutlet weak var foodAmountLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
