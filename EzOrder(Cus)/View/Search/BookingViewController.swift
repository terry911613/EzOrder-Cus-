//
//  BookingViewController.swift
//  EzOrder(Cus)
//
//  Created by Lee Chien Kuan on 2019/6/11.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class BookingViewController: UIViewController {
    @IBOutlet weak var bookingNameView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var timeIntervalView: UIView!
    @IBOutlet weak var peopleView: UIView!
    
    
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeIntervalPicker: UIPickerView!
    @IBOutlet weak var vacancyLabel: UILabel!
    @IBOutlet weak var peoplePicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookingNameView.layer.shadowOpacity = 0.3
//        bookingNameView.layer.shadowPath = UIBezierPath(rect: bookingNameView.bounds).cgPath
//        bookingNameView.layer.shadowRadius = 10
        bookingNameView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        
        dateView.layer.shadowOpacity = 0.3
//        dateView.layer.shadowPath = UIBezierPath(rect: dateView.bounds).cgPath
//        dateView.layer.shadowRadius = 10
        dateView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        
        timeIntervalView.layer.shadowOpacity = 0.3
//        timeIntervalView.layer.shadowPath = UIBezierPath(rect: timeIntervalView.bounds).cgPath
//        timeIntervalView.layer.shadowRadius = 10
        timeIntervalView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        
        peopleView.layer.shadowOpacity = 0.3
//        peopleView.layer.shadowPath = UIBezierPath(rect: peopleView.bounds).cgPath
//        peopleView.layer.shadowRadius = 10
        peopleView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func clickBooking(_ sender: Any) {
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
