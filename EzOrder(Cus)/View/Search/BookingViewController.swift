//
//  BookingViewController.swift
//  EzOrder(Cus)
//
//  Created by Lee Chien Kuan on 2019/6/11.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase

class BookingViewController: UIViewController {
    
    @IBOutlet weak var bookingNameView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var timeIntervalView: UIView!
    @IBOutlet weak var peopleView: UIView!
    
    
    @IBOutlet weak var resNameLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeIntervalPicker: UIPickerView!
    @IBOutlet weak var peoplePicker: UIPickerView!
    
    var timeInterval = ["請選擇時段"] //可訂位時段
    var peopleArray = ["請選擇訂位人數"]
    var resBookingLimit = 0
//    var resBookingLimitArray = [Int]()
    var resID: String?
    var searchbool : Bool?
    var DocumnetID : String?
    var resName: String?
    var dic = [String: String]()
    let formatter = DateFormatter()
    var selectTime: String?
    var selectPeople: String?
    var selectDateString: String?
    var selectDate: Date?
    var resPeriod: String?
    var morning: Int?
    var noon: Int?
    var evening: Int?
    var selectTimeRow: Int?
    
    override func viewDidLoad() {
        if searchbool == true {
            resID = self.DocumnetID
        }
        // 直接抓餐廳的「可訂位人數」 存入totalVacancy
        super.viewDidLoad()
        
        if let resName = resName{
            resNameLabel.text = resName
        }
        
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateFormat = "yyyy年M月d日"
        selectDateString = formatter.string(from: Date())
        
        datePicker.minimumDate = Date()
        bookingNameView.layer.shadowOpacity = 0.3
        bookingNameView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        
        dateView.layer.shadowOpacity = 0.3
        dateView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        
        timeIntervalView.layer.shadowOpacity = 0.3
        timeIntervalView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        
        peopleView.layer.shadowOpacity = 0.3
        peopleView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        
        get(date: Date())
    }
    
    func reset(){
        self.dic.removeAll()
        self.dic["請選擇時段"] = "請選擇訂位人數"
        self.timeInterval.removeAll()
        self.timeInterval = ["請選擇時段"]
        self.peopleArray.removeAll()
        self.peopleArray = ["請選擇訂位人數"]
    }
    
    func get(date: Date){
        timeIntervalPicker.isUserInteractionEnabled = false
        reset()
        let db = Firestore.firestore()
        if let resID = resID{
            db.collection("res").document(resID).collection("booking").document(formatter.string(from: date)).getDocument { (book, error) in
                
                print("fuck")
                if let bookData = book?.data(){
                    print("gg")
                    if let morning = bookData["morning"] as? Int{
                        self.timeIntervalPicker.isUserInteractionEnabled = false
                        self.morning = morning
                        self.dic["9:00"] = String(morning)
                        self.timeInterval.append("9:00")
                        self.timeIntervalPicker.isUserInteractionEnabled = true
                    }
                    if let noon = bookData["noon"] as? Int{
                        self.timeIntervalPicker.isUserInteractionEnabled = false
                        self.noon = noon
                        self.dic["12:00"] = String(noon)
                        self.timeInterval.append("12:00")
                        self.timeIntervalPicker.isUserInteractionEnabled = true
                    }
                    if let evening = bookData["evening"] as? Int{
                        self.timeIntervalPicker.isUserInteractionEnabled = false
                        self.evening = evening
                        self.dic["18:00"] = String(evening)
                        self.timeInterval.append("18:00")
                        self.timeIntervalPicker.isUserInteractionEnabled = true
                    }
                    self.timeIntervalPicker.reloadAllComponents()
                    
                    self.peoplePicker.reloadAllComponents()
                }
                else{
                    print("as")
                    db.collection("res").document(resID).getDocument { (res, error) in
                        if let resData = res?.data(){
                            print("fucdsdk")
                            if let resBookingLimit = resData["resBookingLimit"] as? Int,
                                let resPeriod = resData["resPeriod"] as? String{
                                self.resPeriod = resPeriod
                                self.dic.removeAll()
                                print(resPeriod)
                                for i in resPeriod{
                                    if i == "1"{
                                        self.timeIntervalPicker.isUserInteractionEnabled = false
                                        self.morning = resBookingLimit
                                        self.dic["9:00"] = String(resBookingLimit)
                                        self.timeInterval.append("9:00")
                                        self.timeIntervalPicker.isUserInteractionEnabled = true
                                    }
                                    else if i == "2"{
                                        self.timeIntervalPicker.isUserInteractionEnabled = false
                                        self.noon = resBookingLimit
                                        self.dic["12:00"] = String(resBookingLimit)
                                        self.timeInterval.append("12:00")
                                        self.timeIntervalPicker.isUserInteractionEnabled = true
                                    }
                                    else{
                                        self.timeIntervalPicker.isUserInteractionEnabled = false
                                        self.evening = resBookingLimit
                                        self.dic["18:00"] = String(resBookingLimit)
                                        self.timeInterval.append("18:00")
                                        self.timeIntervalPicker.isUserInteractionEnabled = true
                                    }
                                }
                                self.timeIntervalPicker.reloadAllComponents()
                                self.peoplePicker.reloadAllComponents()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func datePicker(_ sender: UIDatePicker) {
        if datePicker.isSelected{
            get(date: sender.date)
            timeIntervalPicker.selectRow(0, inComponent: 0, animated: true)
            selectDateString = formatter.string(from: sender.date)
            selectDate = sender.date
        }
    }
    
    @IBAction func clickBooking(_ sender: Any) {
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email,
            let resID = resID,
            let resName = resName,
            let selectDate = selectDateString,
            let selectPeople = selectPeople,
            let selectTime = selectTime,
            let date = formatter.date(from: selectDate) {
            
            var bookData: [String: Any] = ["documentID": selectDate,
                                           "date": date,
                                           "resID": resID,
                                           "resName": resName,
                                           "userID": userID]
            if let resPeriod = resPeriod{
                for i in resPeriod{
                    if i == "1"{
                        if selectTime == "9:00"{
                            if let morning = morning{
                                bookData["morning"] = morning - Int(selectPeople)!
                            }
                        }
                        else{
                            if let morning = morning{
                                bookData["morning"] = morning
                            }
                        }
                    }
                    else if i == "2"{
                        if selectTime == "12:00"{
                            if let noon = noon{
                                bookData["noon"] = noon - Int(selectPeople)!
                            }
                        }
                        else{
                            if let noon = noon{
                                bookData["noon"] = noon
                            }
                        }
                    }
                    else{
                        if selectTime == "18:00"{
                            if let evening = evening{
                                bookData["evening"] = evening - Int(selectPeople)!
                            }
                        }
                        else{
                            if let evening = evening{
                                bookData["evening"] = evening
                            }
                        }
                    }
                }
            }
            db.collection("user").document(userID).collection("booking").document(selectDate).setData(bookData)
            db.collection("res").document(resID).collection("booking").document(selectDate).setData(bookData)
            
            let documentID = String(Date().timeIntervalSince1970) + userID
            let bookDetailData: [String: Any] = ["documentID": documentID,
                                                 "dateString": selectDate,
                                                 "userID": userID,
                                                 "resID": resID,
                                                 "resName": resName,
                                                 "date": Date(),
                                                 "people": selectPeople,
                                                 "period": selectTime]
            db.collection("user").document(userID).collection("booking").document(selectDate).collection("bookDetail").document(documentID).setData(bookDetailData)
            db.collection("res").document(resID).collection("booking").document(selectDate).collection("bookDetail").document(documentID).setData(bookDetailData)
            
            let alert = UIAlertController(title: "訂位成功", message: "可到行事曆查看", preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default) { (ok) in
                self.timeIntervalPicker.selectRow(0, inComponent: 0, animated: true)
                self.selectTime = nil
                self.peopleArray.removeAll()
                self.peopleArray = ["請選擇訂位人數"]
                self.peoplePicker.reloadAllComponents()
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
                                                 
        }
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
        }
        else { // pepole picker
            return peopleArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === timeIntervalPicker {
            return timeInterval[row]
        }
        else { // people picker
            return peopleArray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == timeIntervalPicker {
            // 抓取該日期該時段的「已被訂位人數」
            self.peopleArray.removeAll()
            self.peopleArray = ["請選擇訂位人數"]
            selectTimeRow = row
            if row == 0{
                peoplePicker.reloadAllComponents()
                peoplePicker.selectRow(0, inComponent: 0, animated: true)
            }
            else{
                let text = timeInterval[row]
                selectTime = text
                if let people = Int(dic[text]!){
                    if people > 0{
                        for i in 1...people{
                            peopleArray.append(String(i))
                        }
                    }
                }
                peoplePicker.reloadAllComponents()
                peoplePicker.selectRow(0, inComponent: 0, animated: true)
            }
        }
        else{
            if row == 0{
                selectPeople = nil
            }
            else{
                selectPeople = peopleArray[row]
            }
        }
    }
    
}
