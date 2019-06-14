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
    
    var timeInterval = ["請選擇時段", "9:00", "12:00", "18:00"] //可訂位時段
    var totalVacancy = 10
    override func viewDidLoad() {
        // 直接抓餐廳的「可訂位人數」 存入totalVacancy
        super.viewDidLoad()
        datePicker.minimumDate = Date()
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
extension BookingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === timeIntervalPicker {
            return timeInterval.count
        } else { // pepole picker
            return 100
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === timeIntervalPicker {
            return timeInterval[row]
        } else { // people picker
            if row == 0 {
                return "請選擇訂位人數"
            } else {
                return String(row)
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == timeIntervalPicker {
            // 抓取該日期該時段的「已被訂位人數」
            let occupancy = 3
            vacancyLabel.text = String(totalVacancy - occupancy)
        }
    }
    
    
}
