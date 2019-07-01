//
//  RateResViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/6/21.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase

class RateResViewController: UIViewController , UITextViewDelegate{
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var resNameLabel: UILabel!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var commentResTextView: UITextView!
    @IBOutlet weak var rateView: UIImageView!
    @IBOutlet weak var rateSlider: RateSlider!
    
    var resID: String?
    var orderNo: String?
    var resTotalRate: Double?
    var resRateCount: Int?
    var viewHeight: CGFloat?
    
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardObserver()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentResTextView.delegate = self
        commentResTextView.layer.borderWidth = 0.8
        commentResTextView.layer.borderColor = UIColor.gray.cgColor
        commentResTextView.text = "添加些評論吧(選填)"
        commentResTextView.textColor = UIColor.gray
        
        rateSlider.rateResVC = self
        let layer = CAShapeLayer()
        layer.frame = .zero
        // 畫出來的部分才會顯示
        rateSlider.layer.mask = layer
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email,
            let resID = resID,
            let orderNo = orderNo{
            db.collection("user").document(userID).collection("order").document(orderNo).getDocument { (order, error) in
                if let orderData = order?.data(){
                    if let resRate = orderData["resRate"] as? Float,
                        let resComment = orderData["resComment"] as? String{
                        
                        self.commentResTextView.text = resComment
                        self.updateStar(value: resRate)
                        self.blockView.isHidden = false
                    }
                    else{
                        self.blockView.isHidden = true
                    }
                }
            }
            db.collection("res").document(resID).getDocument { (res, error) in
                if let resData = res?.data(){
                    if let resName = resData["resName"] as? String{
                        self.resNameLabel.text = resName
                    }
                    if let resTotalRate = resData["resTotalRate"] as? Double,
                        let resRateCount = resData["resRateCount"] as? Int{
                        self.resTotalRate = resTotalRate
                        self.resRateCount = resRateCount
                    }
                    else{
                        self.resTotalRate = 0
                        self.resRateCount = 0
                    }
                }
            }
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "添加些評論吧(選填)"
            textView.textColor = UIColor.gray
        }
    }
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func okButton(_ sender: UIButton) {
        
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
        
        var comment = ""
        if commentResTextView.text != "添加些評論吧(選填)" {
            comment = commentResTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email,
            let resID = resID,
            let orderNo = orderNo,
            let resTotalRate = resTotalRate,
            let resRateCount = resRateCount{
            
            let commentID = String(Date().timeIntervalSince1970) + userID
            
            let resRateData: [String: Any] = ["resRate": rate,
                                              "resComment": comment]
            db.collection("user").document(userID).collection("order").document(orderNo).updateData(resRateData)
            db.collection("res").document(resID).collection("order").document(orderNo).updateData(resRateData)
            
            let resTotalRateData: [String: Any] = ["resTotalRate": resTotalRate + rate,
                                                   "resRateCount": resRateCount + 1]
            db.collection("res").document(resID).updateData(resTotalRateData)
            
            let resCommentData: [String: Any] = ["documentID": commentID,
                                                 "userID": userID,
                                                 "date": Date(),
                                                 "resRate": rate,
                                                 "resComment": comment]
            db.collection("res").document(resID).collection("resComment").document(commentID).setData(resCommentData)
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    func updateStar(value: Float) {
        let rate = value
        if rate < 2.75 {
            if rate < 0.25 {
                rateView.image = UIImage(named: "rate0")
            } else if rate < 0.75 {
                rateView.image = UIImage(named: "rate05")
            } else if rate < 1.25 {
                rateView.image = UIImage(named: "rate1")
            } else if rate < 1.75 {
                rateView.image = UIImage(named: "rate15")
            } else if rate < 2.25 {
                rateView.image = UIImage(named: "rate2")
            } else {
                rateView.image = UIImage(named: "rate25")
            }
        } else {
            if rate < 3.25 {
                rateView.image = UIImage(named: "rate3")
            } else if rate < 3.75 {
                rateView.image = UIImage(named: "rate35")
            } else if rate < 4.25 {
                rateView.image = UIImage(named: "rate4")
            } else if rate < 4.75 {
                rateView.image = UIImage(named: "rate45")
            } else {
                rateView.image = UIImage(named: "rate5")
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
extension RateResViewController {
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
