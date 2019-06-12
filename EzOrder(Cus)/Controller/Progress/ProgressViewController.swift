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
    
    var igcMenu: IGCMenu?
    var isMenuActive = false
    
    var orderArray = [QueryDocumentSnapshot]()
    var orderNo: String?
    var resID: String?
    var foodNameArray = [String]()
    var foodPriceArray = [Int]()
    
    var totalPrice = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        cartSetting()
        getOrder()
        setUpMenu()
        merchantSetting()
        consumerSetting()
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        getOrder()
//    }
    
    func getOrder(){
        
        let db = Firestore.firestore()
        
        if let userID = Auth.auth().currentUser?.email{
            db.collection("user").document(userID).collection("order").whereField("payStatus", isEqualTo: 0).addSnapshotListener { (order, error) in
                if let order = order{
                    if order.documents.isEmpty == false{
                        if let totalPrice = order.documents[0].data()["totalPrice"] as? Int,
                            let orderNo = order.documents[0].data()["orderNo"] as? String,
                            let resID = order.documents[0].data()["resID"] as? String{
                            
                            self.totalPriceLabel.text = "總共：＄\(totalPrice)"
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
                            if self.isMenuActive {
                                self.payButton.setTitle("付款", for: .normal)
                                self.payButton.setTitleColor(.white, for: .normal)
                                self.igcMenu?.hideCircularMenu()
                                self.isMenuActive = false
                            }
                            else {
                                self.payButton.setTitle("取消", for: .normal)
                                self.payButton.setTitleColor(.red, for: .normal)
                                self.igcMenu?.showCircularMenu()
                                self.isMenuActive = true
                            }
                        }
                    }
                }
            }
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
        // Set Consumer Contact.
        let contact = PKContact()
        var name = PersonNameComponents()
        name.familyName = "EzOrder"
        name.givenName = "Terry"
        contact.name = name;
        
        consumer = TPDConsumer()
        consumer.billingContact = contact
        consumer.requiredBillingAddressFields = []
        
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
            let userID = Auth.auth().currentUser?.email{

            cell.foodNameLabel.text = foodName
            cell.foodImageView.kf.setImage(with: URL(string: foodImage))
            cell.foodPriceLabel.text = "$\(foodPrice)"
            cell.foodAmountLabel.text = "數量：\(foodAmount)"
            
            let db = Firestore.firestore()

            db.collection("user").document(userID).collection("order").document(orderNo).collection("orderFoodDetail").document(foodName).addSnapshotListener({ (foodStatus, error) in
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
        print("=====================================================");
        print("======> didReceivePrime");
        print("Prime : \(prime!)");
        print("total Amount :   \(applePay.cart.totalAmount!)")
        print("Client IP : \(applePay.consumer.clientIP!)")
        print("shippingContact.name : \(applePay.consumer.shippingContact?.name?.givenName) \(applePay.consumer.shippingContact?.name?.familyName)");
        print("shippingContact.emailAddress : \(applePay.consumer.shippingContact?.emailAddress)");
        print("shippingContact.phoneNumber : \(applePay.consumer.shippingContact?.phoneNumber?.stringValue)");
        print("===================================================== \n\n");
        
        
        
        DispatchQueue.main.async {
            let payment = "Use below cURL to proceed the payment.\ncurl -X POST \\\nhttps://sandbox.tappaysdk.com/tpc/payment/pay-by-prime \\\n-H \'content-type: application/json\' \\\n-H \'x-api-key: partner_6ID1DoDlaPrfHw6HBZsULfTYtDmWs0q0ZZGKMBpp4YICWBxgK97eK3RM\' \\\n-d \'{ \n \"prime\": \"\(prime!)\", \"partner_key\": \"partner_6ID1DoDlaPrfHw6HBZsULfTYtDmWs0q0ZZGKMBpp4YICWBxgK97eK3RM\", \"merchant_id\": \"GlobalTesting_CTBC\", \"details\":\"TapPay Test\", \"amount\": \(applePay.cart.totalAmount!.stringValue), \"cardholder\": { \"phone_number\": \"+886923456789\", \"name\": \"Jane Doe\", \"email\": \"Jane@Doe.com\", \"zip_code\": \"12345\", \"address\": \"123 1st Avenue, City, Country\", \"national_id\": \"A123456789\" }, \"remember\": true }\'"
            
//            print(payment)
        }
        
//        let session = URLSession(configuration: .default)
        // 设置URL
        let url = "https://sandbox.tappaysdk.com/tpc/payment/pay-by-prime"
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("Content-Type", forHTTPHeaderField: "application/json​")
        request.setValue("x-api-key", forHTTPHeaderField: "partner_GJdRUgUc6TIiLZtDbsH5joCpqZanYOskAsqk5h3jXAGkxNDjz58rvBpX")
        request.httpMethod = "POST"
        // 设置要post的内容，字典格式
        
//        var cardholder = [String: String]()
//        cardholder["phone_number"] = "+886923456789"
//        cardholder["name"] = "王小明"
//        cardholder["email"] = "LittleMing@Wang.com"
//        cardholder["address"] = "台北市天龍區芝麻街1號1樓"
//        cardholder["national_id"] = "A123456789"
//
//        var postData = [String: Any]()
//        postData["prime"] = prime
//        postData["partner_key"] = "partner_GJdRUgUc6TIiLZtDbsH5joCpqZanYOskAsqk5h3jXAGkxNDjz58rvBpX"
//        postData["merchant_id"] = "merchant.com.TerryLee.EzOrderCus"
//        postData["details"] = "TapPay Test"
//        postData["amount"] = 100
//        postData["cardholder"] = cardholder
        
        let postData: String = "{\"prime\":\"\(prime!)\",\"partner_key\":\"partner_GJdRUgUc6TIiLZtDbsH5joCpqZanYOskAsqk5h3jXAGkxNDjz58rvBpX\",\"merchant_id\":\"merchant.com.TerryLee.EzOrderCus\",\"details\":\"TapPay Test\",\"amount\":\(100),\"cardholder\":{\"phone_number\":\"+886923456789\",\"name\":\"王小明\",\"email\":\"LittleMing@Wang.com\",\"zip_code\":\(100),\"address\":\"台北市天龍區芝麻街1號1樓\",\"national_id\":\"A123456789\"}}"
        
//        let postData: String = "{\"prime\":\"\(prime!)\",\"partner_key\":\"partner_GJdRUgUc6TIiLZtDbsH5joCpqZanYOskAsqk5h3jXAGkxNDjz58rvBpX\",\"merchant_id\":\"merchant.com.TerryLee.EzOrderCus\",\"details\":\"TapPay Test\",\"amount\":\(applePay.cart.totalAmount!.stringValue),\"cardholder\":{\"phone_number\":\"+886923456789\",\"name\":\"Jane Doe\",\"email\":\"Jane@Doe.com\",\"zip_code\":\"12345\",\"address\":\"1231stAvenue,City,Country\",\"national_id\":\"A123456789\"}}"
        
        print(postData)
        
//        let jsonData = try! JSONSerialization.data(withJSONObject: postData)
        
//        JSONSerialization.jsonObject(with: postData, options: .allowFragments)
//        let jsonData = try! JSONSerialization.jsonObject(with: postData, options: .allowFragments)
//        let jsonString = String(data: jsonData, encoding: .utf8)
//        print("jsonString = \(jsonString!)")
  
//        let c = try? JSONSerialization.jsonObject(with: b, options: .allowFragments)
        
//        print(postData)
        
        
        request.httpBody = postData.data(using: .utf8)
//        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            do {
                print(data)
                if let data = data{
                    let r = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                    print("--------------")
                    print(r)
                    print("--------------")
                }
            } catch {
                print("無法連接伺服器:\(error)")
                return
            }
        }
        task.resume()
        
        // 2. If Payment Success, set paymentReault = ture.
        let paymentReault = true;
        applePay.showPaymentResult(paymentReault)
    }
    
    func tpdApplePay(_ applePay: TPDApplePay!, didSuccessPayment result: TPDTransactionResult!) {
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email,
            let orderNo = orderNo,
            let resID = resID{
            
            db.collection("user").document(userID).collection("order").document(orderNo).updateData(["payStatus": 1])
            db.collection("res").document(resID).collection("order").document(orderNo).updateData(["payStatus": 1])
            
            let pointCount = totalPrice/1000
            db.collection("user").document(userID).updateData(["pointCount": pointCount])
            orderArray.removeAll()
            animateProgressTableView()
            totalPriceLabel.text = ""
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

