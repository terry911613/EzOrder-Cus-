//
//  SearcMenuTableViewCell.swift
//  EzOrder(Cus)
//
//  Created by 劉十六 on 2019/6/6.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class SearcMenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var searcMenuTabelImage: UIImageView!
    @IBOutlet weak var searcMenuTableName: UILabel!
    @IBOutlet weak var searcTableMenuMoney: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
