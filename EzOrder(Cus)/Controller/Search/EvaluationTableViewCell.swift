//
//  EvaluationTableViewCell.swift
//  EzOrder(Cus)
//
//  Created by 劉十六 on 2019/6/7.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class EvaluationTableViewCell: UITableViewCell {
    @IBOutlet weak var evaluationImageView: UIImageView!
    @IBOutlet weak var evaluation: UIImageView!
    @IBOutlet weak var evaluationTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
  

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
