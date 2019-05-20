//
//  DateEventTableViewCell.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/20.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class DateEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var restaurantLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
