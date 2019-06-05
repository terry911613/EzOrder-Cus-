//
//  OrderRecordViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/6/4.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class OrderRecordViewController: UIViewController {

    @IBOutlet weak var orderRecordTableView: UITableView!
    
    var restaurantImage = ["AD1", "AD2", "AD3", "AD4", "AD5"]
    var date = ["2019-01-01", "2019-02-02", "2019-03-03", "2019-04-04", "2019-05-05"]
    var price = [1000, 2000, 3000, 4000, 5000]
    var point = [10, 20, 30, 40, 50]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension OrderRecordViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantImage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderRecordCell", for: indexPath) as! OrderRecordTableViewCell
        cell.restaurantImageView.image = UIImage(named: restaurantImage[indexPath.row])
        cell.dateLabel.text = "日期：" + date[indexPath.row]
        cell.priceLabel.text = "價錢：" + String(price[indexPath.row])
        cell.pointLabel.text = "點數：" + String(point[indexPath.row])
        return cell
    }
    
    
}
