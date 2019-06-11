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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            db.collection("user").document(userID).getDocument { (user, error) in
                if let userData = user?.data(){
                    if let pointCount = userData["pointCount"] as? Int{
                        self.pointCountLabel.text = "剩餘\(pointCount)次轉盤機會"
                    }
                }
            }
        }
    }
    
    var point = 0
    @IBAction func clickRotate(_ sender: Any) {
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            db.collection("user").document(userID).getDocument { (user, error) in
                if let userData = user?.data(){
                    if let pointCount = userData["pointCount"] as? Int{
                        if pointCount > 0{
                            self.point = self.wheelRotateImageView.rotateGradually(handler: {
                                db.collection("user").document(userID).updateData(["pointCount": pointCount-1])
                                self.pointCount = pointCount-1
                                self.performSegue(withIdentifier: "alertPointSegue", sender: self)
                            })
                        }
                        else{
                            let alert = UIAlertController(title: "無轉盤機會", message: nil, preferredStyle: .alert)
                            let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
                            alert.addAction(ok)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        
        
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
