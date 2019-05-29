//
//  WheelViewController.swift
//  EzOrder(Cus)
//
//  Created by Lee Chien Kuan on 2019/5/29.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class WheelViewController: UIViewController {

    @IBOutlet weak var wheelRotateImageView: RotateImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var point = 0
    @IBAction func clickRotate(_ sender: Any) {
        point = wheelRotateImageView.rotateGradually(handler: {
            self.performSegue(withIdentifier: "alertPointSegue", sender: self)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "alertPointSegue" {
            if let wheelAlertVC = segue.destination as? WheelAlertViewController {
                wheelAlertVC.point = point
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
