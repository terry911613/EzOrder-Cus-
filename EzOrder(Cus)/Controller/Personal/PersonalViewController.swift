//
//  PersonalViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/15.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class PersonalViewController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var personalTableView: UITableView!
    var personalArray = ["收藏餐廳", "行事曆", "消費記錄", "轉盤", "修改個人資訊", "幫助文件"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getInfo()
    }
    
    func getInfo(){
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            db.collection("user").document(userID).addSnapshotListener { (user, error) in
                if let user = user,
                    let userData = user.data(){
                    if let userImage = userData["userImage"] as? String,
                        let userName = userData["userName"] as? String,
                        let userPhone = userData["userPhone"] as? String{
                        
                        self.userImageView.kf.setImage(with: URL(string: userImage))
                        self.nameLabel.text = userName
                        self.phoneLabel.text = "電話：\(userPhone)"
                    }
                    if let totalPoint = userData["totalPoint"] as? Int{
                        self.pointLabel.text = "點數：\(totalPoint)"
                    }
                    else{
                        self.pointLabel.text = "尚未擁有任何點數"
                    }
                }
            }
        }
    }
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "unwindToLogin", sender: self)
        }
        catch{
            print("error, there was a problem logging out")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
extension PersonalViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "personalCell", for: indexPath)
        cell.selectionStyle = .none
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
