//
//  resCommentTableViewCell.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/6/24.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class ResCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var rateView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
