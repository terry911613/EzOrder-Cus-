//
//  ProgressViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/15.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import PassKit
import TPDirect

class ProgressViewController: UIViewController {
    
    var merchant: TPDMerchant!
    var consumer: TPDConsumer!
    var cart: TPDCart!
    var applePay: TPDApplePay!
    var applePayButton : PKPaymentButton!
    
    @IBOutlet weak var totalMoneyLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    
    var igcMenu: IGCMenu?
    var isMenuActive = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMenu()
        
        merchantSetting()
        consumerSetting()
        cartSetting()
    }
    
    @IBAction func payButton(_ sender: UIButton) {
        if isMenuActive {
            payButton.setTitle("付款", for: .normal)
            payButton.setTitleColor(.white, for: .normal)
            igcMenu?.hideCircularMenu()
            isMenuActive = false
        }
        else {
            payButton.setTitle("取消", for: .normal)
            payButton.setTitleColor(.red, for: .normal)
            igcMenu?.showCircularMenu()
            isMenuActive = true
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
//        merchant.applePayMerchantIdentifier = "terry911613_ESUN"
//        merchant.applePayMerchantIdentifier = "GlobalTesting_CTBC"
        merchant.applePayMerchantIdentifier = "merchant.com.TerryLee.EzOrder-Cus-" // Your Apple Pay Merchant ID (https://developer.apple.com/account/ios/identifier/merchant)
        merchant.countryCode = "TW"
        merchant.currencyCode = "TWD"
        merchant.supportedNetworks = [.amex, .masterCard, .visa]
        
        // Set Shipping Method.
        let shipping1 = PKShippingMethod()
        shipping1.identifier = "TapPayExpressShippint024"
        shipping1.detail = "Ships in 24 hours"
        shipping1.amount = NSDecimalNumber(string: "10.0");
        shipping1.label = "Shipping 24"
        
        let shipping2 = PKShippingMethod()
        shipping2.identifier = "TapPayExpressShippint006";
        shipping2.detail = "Ships in 6 hours";
        shipping2.amount = NSDecimalNumber(string: "50.0");
        shipping2.label = "Shipping 6";
        //        merchant.shippingMethods            = [shipping1, shipping2];
        
    }
    
    func consumerSetting() {
        // Set Consumer Contact.
        let contact = PKContact()
        var name    = PersonNameComponents()
        name.familyName = "Cherri"
        name.givenName = "TapPay"
        contact.name = name;
        
        consumer = TPDConsumer()
        consumer.billingContact = contact
        consumer.shippingContact = contact
        consumer.requiredShippingAddressFields = []
        consumer.requiredBillingAddressFields = []
        
    }
    
    func cartSetting() {
        cart = TPDCart()
        let food = TPDPaymentItem(itemName: "滷肉飯", withAmount: NSDecimalNumber(string: "35"), withIsVisible: false)
        cart.add(food)
        let food1 = TPDPaymentItem(itemName: "雞肉飯", withAmount: NSDecimalNumber(string: "40"), withIsVisible: false)
        cart.add(food1)
        
    }
    
    @IBAction func unwindSegueToProgress(segue: UIStoryboardSegue){
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
            let ok = UIAlertAction(title: "ok", style: .default) { (ok) in
                //                self.menuButton.setImage(UIImage(named: "Pay"), for: .normal)
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
            //            menuButton.setImage(UIImage(named: "Pay"), for: .normal)
            performSegue(withIdentifier: "creditCardSegue", sender: self)
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
            print(payment)
            
        }
        
        // 2. If Payment Success, set paymentReault = ture.
        let paymentReault = true;
        applePay.showPaymentResult(paymentReault)
    }
    
    func tpdApplePay(_ applePay: TPDApplePay!, didSuccessPayment result: TPDTransactionResult!) {
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
    
    
}
