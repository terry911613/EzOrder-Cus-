//
//  RateDishViewController.swift
//  EzOrder(Cus)
//
//  Created by Lee Chien Kuan on 2019/6/12.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase

class RateDishViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var dishNameLabel: UILabel!
    @IBOutlet weak var rateSlider: RateSlider!
    @IBOutlet weak var rateImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var isCommentedView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var alertView: UIView!
    
    var dishName: String?
    var orderNo: String?
    var resID: String?
    var typeName: String?
    var foodRate: Double?
    var foodRateCount: Double?
    var viewHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let rectShape = CAShapeLayer()
//        rectShape.bounds = headerView.frame
//        rectShape.position = headerView.center
//        rectShape.path = UIBezierPath(roundedRect: headerView.bounds, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
//        headerView.layer.mask = rectShape

        addKeyboardObserver()
        commentTextView.delegate = self
        rateSlider.parentVC = self
        
        commentTextView.layer.borderWidth = 0.5
        commentTextView.layer.borderColor = UIColor.gray.cgColor
        
        let layer = CAShapeLayer()
        layer.frame = .zero
        // 畫出來的部分才會顯示
        rateSlider.layer.mask = layer
        
        dishNameLabel.text = dishName
        
        commentTextView.text = "添加些評論吧(選填)"
        commentTextView.textColor = UIColor.lightGray
        // Do any additional setup after loading the view.
        let db = Firestore.firestore()
        if let resID = resID,
            let typeName = typeName,
            let dishName = dishName,
            let orderNo = orderNo,
            let userID = Auth.auth().currentUser?.email{
            db.collection("res").document(resID).collection("foodType").document(typeName).collection("menu").document(dishName).getDocument { (food, error) in
                if let foodData = food?.data(){
                    if let foodTotalRate = foodData["foodTotalRate"] as? Double,
                        let foodRateCount = foodData["foodRateCount"] as? Double{
                        self.foodRate = foodTotalRate
                        self.foodRateCount = foodRateCount
                    }
                }
            }
            
            db.collection("user").document(userID).collection("order").document(orderNo).collection("orderFoodDetail").document(dishName).getDocument { (food, error) in
                print("ff")
                if let foodData = food?.data(){
                    print("ss")
                    if let foodRate = foodData["foodRate"] as? Float,
                        let foodComment = foodData["foodComment"] as? String{
                        self.commentTextView.text = foodComment
                        self.updateStar(value: foodRate)
                        self.isCommentedView.isHidden = false
                        self.submitButton.isEnabled = false
                    }
                    else{
                        self.isCommentedView.isHidden = true
                    }
                }
            }
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "添加些評論吧(選填)"
            textView.textColor = UIColor.lightGray
        }
    }
    func updateStar(value: Float) {
        let rate = value
        if rate < 2.75 {
            if rate < 0.25 {
                rateImageView.image = UIImage(named: "rate0")
            } else if rate < 0.75 {
                rateImageView.image = UIImage(named: "rate05")
            } else if rate < 1.25 {
                rateImageView.image = UIImage(named: "rate1")
            } else if rate < 1.75 {
                rateImageView.image = UIImage(named: "rate15")
            } else if rate < 2.25 {
                rateImageView.image = UIImage(named: "rate2")
            } else {
                rateImageView.image = UIImage(named: "rate25")
            }
        } else {
            if rate < 3.25 {
                rateImageView.image = UIImage(named: "rate3")
            } else if rate < 3.75 {
                rateImageView.image = UIImage(named: "rate35")
            } else if rate < 4.25 {
                rateImageView.image = UIImage(named: "rate4")
            } else if rate < 4.75 {
                rateImageView.image = UIImage(named: "rate45")
            } else {
                rateImageView.image = UIImage(named: "rate5")
            }
        }
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickSubmit(_ sender: Any) {
        
        let alert = UIAlertController(title: "評價評分只能評一次", message: "確認送出？", preferredStyle: .alert)
        let ok = UIAlertAction(title: "確定", style: .default) { (ok) in
            self.upload()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func upload(){
        var rate = 0.0
        let sliderValue = rateSlider.value
        if sliderValue < 2.75 {
            if sliderValue < 0.25 {
                rate = 0
            } else if sliderValue < 0.75 {
                rate = 0.5
            } else if sliderValue < 1.25 {
                rate = 1
            } else if sliderValue < 1.75 {
                rate = 1.5
            } else if sliderValue < 2.25 {
                rate = 2
            } else {
                rate = 2.5
            }
        } else {
            if sliderValue < 3.25 {
                rate = 3
            } else if sliderValue < 3.75 {
                rate = 3.5
            } else if sliderValue < 4.25 {
                rate = 4
            } else if sliderValue < 4.75 {
                rate = 4.5
            } else {
                rate = 5
            }
        }
        print(rate)
        var comment = ""
        if commentTextView.text != "添加些評論吧(選填)" {
            comment = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email,
            let orderNo = orderNo,
            let dishName = dishName,
            let resID = resID,
            let typeName = typeName,
            let foodRate = foodRate,
            let foodRateCount = foodRateCount{
            
            let timeStamp = Date().timeIntervalSince1970
            let commentID = String(timeStamp) + userID
            
            let orderData: [String: Any] = ["foodRate": rate, "foodComment": comment]
            db.collection("user").document(userID).collection("order").document(orderNo).collection("orderFoodDetail").document(dishName).updateData(orderData)
            db.collection("res").document(resID).collection("order").document(orderNo).collection("orderFoodDetail").document(dishName).updateData(orderData)
            
            let foodData: [String: Any] = ["foodTotalRate": foodRate + rate, "foodRateCount": foodRateCount + 1]
            db.collection("res").document(resID).collection("foodType").document(typeName).collection("menu").document(dishName).updateData(foodData)
            
            let foodCommentData: [String: Any] = ["foodComment": comment, "foodRate": rate, "date": Date(), "userID": userID]
            db.collection("res").document(resID).collection("foodType").document(typeName).collection("menu").document(dishName).collection("foodComment").document(commentID).setData(foodCommentData)
            
            dismiss(animated: true, completion: nil)
        }
        // 上傳rate和comment
    }
}
extension RateDishViewController {
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        // 能取得鍵盤高度就讓view上移鍵盤高度，否則上移view的1/3高度
        viewHeight = view.frame.height
        let alertViewHeight = self.alertView.frame.height
        let alertViewLeftBottomY = alertView.frame.origin.y + alertViewHeight
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            
            let overlap = alertViewLeftBottomY + keyboardRect.height - viewHeight!
            if overlap > -10 {
                self.alertView.frame.origin.y -= (overlap + 10)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.alertView.center = self.view.center
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
