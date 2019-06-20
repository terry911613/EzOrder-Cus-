//
//  WheelViewController.swift
//  EzOrder(Cus)
//
//  Created by Lee Chien Kuan on 2019/5/29.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase

class WheelViewController: UIViewController {

    @IBOutlet weak var wheelRotateImageView: RotateImageView!
    @IBOutlet weak var pointCountLabel: UILabel!
    
    var pointCount: Int?
    var getPointCount = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            db.collection("user").document(userID).getDocument { (user, error) in
                if let userData = user?.data(){
                    if let pointCount = userData["pointCount"] as? Int{
                        self.pointCount = pointCount
                        self.pointCountLabel.text = "剩餘\(pointCount)次轉盤機會"
                        self.getPointCount = true
                    }
                    else{
                        self.pointCountLabel.text = "無消費記錄"
                    }
                    if userData["totalPoint"] as? Int == nil{
                        db.collection("user").document(userID).updateData(["totalPoint": 0])
                    }
                }
            }
        }
    }
    
    var point = 0
    @IBAction func clickRotate(_ sender: Any) {
        
        if getPointCount {
            let db = Firestore.firestore()
            if let userID = Auth.auth().currentUser?.email{
                db.collection("user").document(userID).getDocument { (user, error) in
                    if let userData = user?.data(){
                        if var pointCount = userData["pointCount"] as? Int,
                            let totalPoint = userData["totalPoint"] as? Int{
                            if pointCount > 0{
                                pointCount -= 1
                                self.pointCount = pointCount
                                self.pointCountLabel.text = "剩餘\(pointCount)次轉盤機會"
                                self.point = self.wheelRotateImageView.rotateGradually(handler: {
                                    
                                    db.collection("user").document(userID).updateData(["pointCount": pointCount,
                                                                                       "totalPoint": totalPoint + self.point])
                                    
                                    self.performSegue(withIdentifier: "alertPointSegue", sender: self)
                                })
                            }
                            else{
                                self.noChanceAlert()
                            }
                        }
                    }
                }
            }
        }
        else{
            noChanceAlert()
        }
    }
    
    func noChanceAlert(){
        let alert = UIAlertController(title: "無轉盤機會", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "alertPointSegue" {
            if let wheelAlertVC = segue.destination as? WheelAlertViewController {
                wheelAlertVC.point = point
                if let pointCount = pointCount{
                    wheelAlertVC.pointCount = pointCount
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
