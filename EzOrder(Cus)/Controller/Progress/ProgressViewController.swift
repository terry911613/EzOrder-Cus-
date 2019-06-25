//
//  ProgressViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/15.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Kingfisher
import PassKit
import TPDirect
import Firebase
import ViewAnimator

class ProgressViewController: UIViewController {
    
    var merchant: TPDMerchant!
    var consumer: TPDConsumer!
    var cart: TPDCart!
    var applePay: TPDApplePay!
    
    var applePayButton : PKPaymentButton!
    
    @IBOutlet weak var progressTableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var serviceBellButton: UIBarButtonItem!
    @IBOutlet weak var tableLabel: UILabel!
    
    var igcMenu: IGCMenu?
    var isMenuActive = false
    var isUsePoint = false
    
    var orderArray = [QueryDocumentSnapshot]()
    var orderNo: String?
    var resID: String?
    var foodNameArray = [String]()
    var foodPriceArray = [Int]()
    
    var totalPrice = 0
    var totalPoint: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableLabel.text = ""
        
//        cartSetting()
        getOrder()
        setUpMenu()
        merchantSetting()
        consumerSetting()
        
    }
    
    func getOrder(){
        
        let db = Firestore.firestore()
        
        if let userID = Auth.auth().currentUser?.email{
            db.collection("user").document(userID).collection("order").whereField("payStatus", isEqualTo: 0).addSnapshotListener { (order, error) in
                if let order = order{
                    if order.documents.isEmpty == false{
                        if let totalPrice = order.documents[0].data()["totalPrice"] as? Int,
                            let orderNo = order.documents[0].data()["orderNo"] as? String,
                            let resID = order.documents[0].data()["resID"] as? String,
                            let tableNo = order.documents[0].data()["tableNo"] as? Int{
                            
                            self.totalPriceLabel.text = "總共：＄\(totalPrice)"
                            self.tableLabel.text = "\(tableNo)桌"
                            self.orderNo = orderNo
                            self.resID = resID
                            self.totalPrice = totalPrice
                            db.collection("user").document(userID).collection("order").document(orderNo).collection("orderFoodDetail").addSnapshotListener { (currentOrder, error) in
                                if let currentOrder = currentOrder{
                                    if currentOrder.documents.isEmpty{
                                        self.orderArray.removeAll()
                                        self.progressTableView.reloadData()
                                    }
                                    else{
                                        let documentChange = currentOrder.documentChanges[0]
                                        if documentChange.type == .added{
                                            self.orderArray = currentOrder.documents
                                            self.animateProgressTableView()
                                            
                                            self.cart = TPDCart()
                                            for food in currentOrder.documents{
                                                if let foodName = food.data()["foodName"] as? String,
                                                    let foodPrice = food.data()["foodPrice"] as? Int,
                                                    let foodAmount = food.data()["foodAmount"] as? Int{
                                                    
                                                    let food = TPDPaymentItem(itemName: "\(foodName)    \(foodAmount)份", withAmount: NSDecimalNumber(string: "\(foodPrice*foodAmount)"), withIsVisible: true)
                                                    self.cart.add(food)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            db.collection("user").document(userID).collection("order").document(orderNo).collection("serviceBellStatus").document("isServiceBell").addSnapshotListener({ (serviceBell, error) in
                                if let serviceBellData = serviceBell?.data(){
                                    if let serviceBellStatus = serviceBellData["serviceBellStatus"] as? Int{
                                        if serviceBellStatus == 0{
                                            self.serviceBellButton.image = UIImage(named: "服務鈴")
                                        }
                                        else{
                                            self.serviceBellButton.image = UIImage(named: "服務鈴亮燈")
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            }
            
            
        }
    }
    
    func animateProgressTableView(){
        let animations = [AnimationType.from(direction: .top, offset: 30.0)]
        progressTableView.reloadData()
        UIView.animate(views: progressTableView.visibleCells, animations: animations, completion: nil)
    }
    
    @IBAction func seviceBellButton(_ sender: UIBarButtonItem) {
        clickServiceBell()
    }
    
    func clickServiceBell(){
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email,
            let orderNo = orderNo,
            let resID = resID{
            db.collection("user").document(userID).collection("order").document(orderNo).collection("serviceBellStatus").document("isServiceBell").getDocument { (serviceBell, error) in
                if let serviceBellData = serviceBell?.data(){
                    if let serviceBellStatus = serviceBellData["serviceBellStatus"] as? Int{
                        if serviceBellStatus == 0{
                            db.collection("user").document(userID).collection("order").document(orderNo).collection("serviceBellStatus").document("isServiceBell").updateData(["serviceBellStatus": 1])
                            db.collection("res").document(resID).collection("order").document(orderNo).collection("serviceBellStatus").document("isServiceBell").updateData(["serviceBellStatus": 1])
                        }
                        else{
                            db.collection("user").document(userID).collection("order").document(orderNo).collection("serviceBellStatus").document("isServiceBell").updateData(["serviceBellStatus": 0])
                            db.collection("res").document(resID).collection("order").document(orderNo).collection("serviceBellStatus").document("isServiceBell").updateData(["serviceBellStatus": 0])
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func payButton(_ sender: UIButton) {
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email,
            let orderNo = orderNo{
            db.collection("user").document(userID).collection("order").document(orderNo).collection("orderCompleteStatus").document("isOrderComplete").getDocument { (orderStatus, error) in
                if let orderStatusData = orderStatus?.data(){
                    if let orderCompleteStatus = orderStatusData["orderCompleteStatus"] as? Int{
                        if orderCompleteStatus == 0{
                            let alert = UIAlertController(title: "餐點還沒到齊", message: "請等餐點到期後再付款", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
                            alert.addAction(ok)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else{
                            db.collection("user").document(userID).getDocument { (user, error) in
                                if let userData = user?.data(){
                                    if let totalPoint = userData["totalPoint"] as? Int{
                                        if totalPoint > 0{
                                            if self.isMenuActive == false{
                                                let alert = UIAlertController(title: "剩餘\(totalPoint)點", message: "使用點數折抵？", preferredStyle: .alert)
                                                let ok = UIAlertAction(title: "使用", style: .default, handler: { (ok) in
                                                    let point = TPDPaymentItem(itemName: "點數折抵", withAmount: NSDecimalNumber(string: "\(-totalPoint)"), withIsVisible: true)
                                                    self.cart.add(point)
                                                    self.isUsePoint = true
                                                    self.totalPoint = totalPoint
                                                    self.clickPay()
                                                })
                                                let cancel = UIAlertAction(title: "不使用", style: .cancel, handler: { (ok) in
                                                    self.isUsePoint = false
                                                    self.clickPay()
                                                })
                                                alert.addAction(ok)
                                                alert.addAction(cancel)
                                                self.present(alert, animated: true, completion: nil)
                                            }
                                            else{
                                                self.clickPay()
                                            }
                                            
                                        }
                                        else{
                                            self.clickPay()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func clickPay(){
        self.isMenuActive = !self.isMenuActive
        if self.isMenuActive {
            self.payButton.setTitle("取消", for: .normal)
            self.payButton.setTitleColor(.red, for: .normal)
            self.igcMenu?.showCircularMenu()
        }
        else {
            self.payButton.setTitle("付款", for: .normal)
            self.payButton.setTitleColor(.white, for: .normal)
            self.igcMenu?.hideCircularMenu()
        }
    }
    
    func didClickApplePayButton() {
        applePay = TPDApplePay.setupWthMerchant(merchant, with: consumer, with: cart, withDelegate: self)
        applePay.startPayment()
    }
    func merchantSetting() {
        merchant = TPDMerchant()
        merchant.merchantName = "EzOrder"
        merchant.merchantCapability = .capability3DS;
        merchant.applePayMerchantIdentifier = "merchant.com.TerryLee.EzOrderCus" // Your Apple Pay Merchant ID (https://developer.apple.com/account/ios/identifier/merchant)
        merchant.countryCode = "TW"
        merchant.currencyCode = "TWD"
        merchant.supportedNetworks = [.amex, .masterCard, .visa]
    }
    func consumerSetting() {
        let contact = PKContact()
        var name = PersonNameComponents()
        name.familyName = "EzOrder"
        name.givenName = "Terry"
        contact.name = name;
        consumer = TPDConsumer()
        consumer.billingContact = contact
        consumer.requiredBillingAddressFields = [.email, .name, .phone]
    }
    func cartSetting() {
        cart = TPDCart()
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email,
            let orderNo = orderNo{
            db.collection("user").document(userID).collection("order").document(orderNo).collection("orderFoodDetail").getDocuments { (food, error) in
                if let food = food{
                    if food.documents.isEmpty == false{
                        for food in food.documents{
                            if let foodName = food.data()["foodName"] as? String,
                                let foodPrice = food.data()["foodPrice"] as? Int,
                                let foodAmount = food.data()["foodAmount"] as? Int{
                                
                                let food = TPDPaymentItem(itemName: "\(foodName)*\(foodAmount)", withAmount: NSDecimalNumber(string: "\(foodPrice*foodAmount)"), withIsVisible: true)
                                self.cart.add(food)
                            }
                        }
                    }
                }
            }
        }
        
//        let food = TPDPaymentItem(itemName: "滷肉飯", withAmount: NSDecimalNumber(string: "35"), withIsVisible: true)
//        cart.add(food)
//        let food1 = TPDPaymentItem(itemName: "雞肉飯", withAmount: NSDecimalNumber(string: "35"), withIsVisible: true)
//        cart.add(food1)
//        let food2 = TPDPaymentItem(itemName: "貢丸湯", withAmount: NSDecimalNumber(string: "20"), withIsVisible: true)
//        cart.add(food2)
//        let food3 = TPDPaymentItem(itemName: "燙青菜", withAmount: NSDecimalNumber(string: "25"), withIsVisible: true)
//        cart.add(food3)
        
    }
    
    @IBAction func unwindSegueToProgress(segue: UIStoryboardSegue){
    }
}

extension ProgressViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "progressCell", for: indexPath) as! ProgressTableViewCell
        let order = orderArray[indexPath.row]
        if let foodName = order.data()["foodName"] as? String,
            let foodImage = order.data()["foodImage"] as? String,
            let foodPrice = order.data()["foodPrice"] as? Int,
            let foodAmount = order.data()["foodAmount"] as? Int,
            let orderNo = order.data()["orderNo"] as? String,
            let documentID = order.data()["documentID"] as? String,
            let userID = Auth.auth().currentUser?.email{

            cell.foodNameLabel.text = foodName
            cell.foodImageView.kf.setImage(with: URL(string: foodImage))
            cell.foodPriceLabel.text = "$\(foodPrice)"
            cell.foodAmountLabel.text = "數量：\(foodAmount)"
            cell.statusLabel.text = "準備中"
            cell.statusLabel.textColor = .red
            
            let db = Firestore.firestore()
            
            db.collection("user").document(userID).collection("order").document(orderNo).collection("orderFoodDetail").document(documentID).addSnapshotListener({ (foodStatus, error) in
                print(orderNo)
                if let foodStatusData = foodStatus?.data(){
                    if let orderFoodStatus = foodStatusData["orderFoodStatus"] as? Int{
                        if orderFoodStatus == 0{
                            cell.statusLabel.text = "準備中"
                            cell.statusLabel.textColor = .red
                        }
                        else{
                            cell.statusLabel.text = "已送達"
                            cell.statusLabel.textColor = .green
                        }
                    }
                }
            })
        }
        return cell
    }
}
    
extension ProgressViewController: IGCMenuDelegate{
    
    func setUpMenu(){
        igcMenu = IGCMenu()
        igcMenu?.menuButton = self.payButton   //Grid menu setup
        igcMenu?.menuSuperView = self.view      //Pass reference of menu button super view
        igcMenu?.disableBackground = true       //Enable/disable menu background
        igcMenu?.numberOfMenuItem = 3           //Number of menu items to display
        //Menu background. It can be BlurEffectExtraLight,BlurEffectLight,BlurEffectDark,Dark or None
        igcMenu?.backgroundType = .BlurEffectDark
        igcMenu?.menuItemsNameArray = ["Cash", "Apply Pay", "Credit Card"]
        
        let cashBackgroundColor = UIColor(red: 33/255.0, green: 180/255.0, blue: 227/255.0, alpha: 1.0)
        let applePayBackgroundColor = UIColor(red: 139/255.0, green: 116/255.0, blue: 240/255.0, alpha: 1.0)
        let creditCardBackgroundColor = UIColor(red: 241/255.0, green: 118/255.0, blue: 121/255.0, alpha: 1.0)
        igcMenu?.menuBackgroundColorsArray = [cashBackgroundColor, applePayBackgroundColor, creditCardBackgroundColor]
        
        igcMenu?.menuImagesNameArray = ["Cash", "ApplePay", "CreditCard"]
        igcMenu?.delegate = self
    }
    
    func igcMenuSelected(selectedMenuName: String, atIndex index: Int) {
        
        if selectedMenuName == "Cash"{
            let alert = UIAlertController(title: "", message: "服務生趕路中", preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default) { (ok) in
                self.resetPayButton()
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        else if selectedMenuName == "Apply Pay"{
            didClickApplePayButton()
            resetPayButton()
        }
        else{
            let creditCardVC = storyboard?.instantiateViewController(withIdentifier: "creditCardVC") as! CreditCardViewController
            navigationController?.pushViewController(creditCardVC, animated: true)
            resetPayButton()
        }
    }
    func resetPayButton(){
        payButton.setTitle("付款", for: .normal)
        payButton.setTitleColor(.white, for: .normal)
        self.igcMenu?.hideCircularMenu()
        self.isMenuActive = false
    }
}
    
extension ProgressViewController: TPDApplePayDelegate{
    
    func tpdApplePay(_ applePay: TPDApplePay!, didReceivePrime prime: String!) {
        
        let url = URL(string: "https://sandbox.tappaysdk.com/tpc/payment/pay-by-prime")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json​", forHTTPHeaderField: "Content-Type")
        request.addValue("partner_GJdRUgUc6TIiLZtDbsH5joCpqZanYOskAsqk5h3jXAGkxNDjz58rvBpX", forHTTPHeaderField: "x-api-key")
        
        DispatchQueue.main.async {
            
            let test = ["prime":prime!,"partner_key":"partner_GJdRUgUc6TIiLZtDbsH5joCpqZanYOskAsqk5h3jXAGkxNDjz58rvBpX","merchant_id": "terry911613_ESUN","details":"TapPay Test","amount":applePay.cart.totalAmount!.stringValue,"cardholder":["phone_number":"+886923456789","name":"sun","email":"LittleMing@Wang.com"]] as [String : Any]
            let data = try?  JSONSerialization.data(withJSONObject: test)
            let task = URLSession.shared.uploadTask(with: request, from: data){(data, response, error) in
                print("data:\(String(data: data!, encoding: .utf8))")
                print("response:\(response)")
                print("error\(error)")
            }
            task.resume()
        }
        // 2. If Payment Success, set paymentReault = ture.
        let paymentReault = true;
        applePay.showPaymentResult(paymentReault)
    }
    
    func tpdApplePay(_ applePay: TPDApplePay!, didSuccessPayment result: TPDTransactionResult!) {
        
        tableLabel.text = ""
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email,
            let orderNo = orderNo,
            let resID = resID{
            
            db.collection("user").document(userID).collection("order").document(orderNo).updateData(["payStatus": 1])
            db.collection("res").document(resID).collection("order").document(orderNo).updateData(["payStatus": 1])
            
            if isUsePoint{
                db.collection("user").document(userID).updateData(["totalPoint": 0])
                if let totalPoint = totalPoint{
                    db.collection("user").document(userID).collection("order").document(orderNo).updateData(["totalPrice": totalPrice - totalPoint, "usePoint": totalPoint, "isUsePoint": 1])
                    db.collection("res").document(resID).collection("order").document(orderNo).updateData(["totalPrice": totalPrice - totalPoint, "usePoint": totalPoint, "isUsePoint": 1])
                }
            }
            
            db.collection("user").document(userID).getDocument { (user, error) in
                if let userData = user?.data(){
                    if let userPointCount = userData["pointCount"] as? Int{
                        let pointCount = self.totalPrice/100
                        db.collection("user").document(userID).updateData(["pointCount": userPointCount + pointCount])
                        self.orderArray.removeAll()
                        self.animateProgressTableView()
                        self.totalPriceLabel.text = ""
                    }
                }
            }
        }
        
        print("=====================================================")
        print("Apple Pay Did Success ==> Amount : \(result.amount.stringValue)")
        
        print("shippingContact.name : \(applePay.consumer.shippingContact?.name?.givenName) \( applePay.consumer.shippingContact?.name?.familyName)")
        print("shippingContact.emailAddress : \(applePay.consumer.shippingContact?.emailAddress)")
        print("shippingContact.phoneNumber : \(applePay.consumer.shippingContact?.phoneNumber?.stringValue)")
        
        
        print("===================================================== \n\n")
    }
    
    func tpdApplePay(_ applePay: TPDApplePay!, didFailurePayment result: TPDTransactionResult!) {
        print("=====================================================")
        print("Apple Pay Did Failure ==> Message : \(result.message), ErrorCode : \(result.status)")
        print("===================================================== \n\n")
    }
    
    func tpdApplePayDidStartPayment(_ applePay: TPDApplePay!) {
        //
        print("=====================================================")
        print("Apple Pay On Start")
        print("===================================================== \n\n")
    }
    
    func tpdApplePayDidCancelPayment(_ applePay: TPDApplePay!) {
        //
        print("=====================================================")
        print("Apple Pay Did Cancel")
        print("===================================================== \n\n")
    }
    
    func tpdApplePayDidFinishPayment(_ applePay: TPDApplePay!) {
        //
        print("=====================================================")
        print("Apple Pay Did Finish")
        print("===================================================== \n\n")
    }
}

