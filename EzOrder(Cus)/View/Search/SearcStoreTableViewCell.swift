//
//  SearcStoreTableViewCell.swift
//  EzOrder(Cus)
//
//  Created by 劉十六 on 2019/6/6.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class SearcStoreTableViewCell: UITableViewCell {

    @IBOutlet weak var StoreImage: UIImageView!
    @IBOutlet weak var StoreName: UILabel!
    @IBOutlet weak var rateView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
