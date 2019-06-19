//
//  PersonalTableViewCell.swift
//  EzOrder(Cus)
//
//  Created by 劉十六 on 2019/6/19.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class PersonalTableViewCell: UITableViewCell {

    @IBOutlet weak var personalLabel: UILabel!
    @IBOutlet weak var personalImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
