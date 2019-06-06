//
//  PersonalViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/15.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class PersonalViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    
    @IBOutlet weak var personalTableView: UITableView!
    var personalArray = ["收藏餐廳", "行事曆", "消費記錄", "轉盤", "修改個人資訊", "幫助文件"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
extension PersonalViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "personalCell", for: indexPath)
        cell.imageView?.image = UIImage(named: "Cash")
        cell.textLabel?.text = personalArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let favoriteVC = storyboard?.instantiateViewController(withIdentifier: "favoriteVC") as! FavoriteViewController
            navigationController?.pushViewController(favoriteVC, animated: true)
        }
        else if indexPath.row == 1{
            let calendarVC = storyboard?.instantiateViewController(withIdentifier: "calendarVC") as! CalendarViewController
            navigationController?.pushViewController(calendarVC, animated: true)
        }
        else if indexPath.row == 2{
            let orderRecordVC = storyboard?.instantiateViewController(withIdentifier: "orderRecordVC") as! OrderRecordViewController
            navigationController?.pushViewController(orderRecordVC, animated: true)
        }
        else if indexPath.row == 3 {
            let wheelVC = storyboard?.instantiateViewController(withIdentifier: "wheelVC") as! WheelViewController
            navigationController?.pushViewController(wheelVC, animated: true)
        }
        else if indexPath.row == 4{
            performSegue(withIdentifier: "editPersonalSegue", sender: self)
        }
        else{
            
        }
    }
}
