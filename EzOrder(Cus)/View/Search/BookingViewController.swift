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
    
    
    @IBOutlet weak var resNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeIntervalPicker: UIPickerView!
    @IBOutlet weak var vacancyLabel: UILabel!
    @IBOutlet weak var peoplePicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookingNameView.layer.shadowOpacity = 0.3
        bookingNameView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        
        dateView.layer.shadowOpacity = 0.3
        dateView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        
        timeIntervalView.layer.shadowOpacity = 0.3
        timeIntervalView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        
        peopleView.layer.shadowOpacity = 0.3
        peopleView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
    }
    
    @IBAction func clickBooking(_ sender: Any) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
