//
//  CreditCardPayViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/6/3.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import TPDirect

class CreditCardPayViewController: UIViewController {
    
    @IBOutlet weak var payView: UIView!
    @IBOutlet weak var payButton: UIButton!
    
    var tpdForm : TPDForm!
    var tpdCard : TPDCard!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tpdForm = TPDForm.setup(withContainer: payView)
        self.tpdCard = TPDCard.setup(self.tpdForm)
        self.tpdForm.setErrorColor(UIColor.red)
        
        self.tpdForm.onFormUpdated { (status) in
            self.payButton.isEnabled = status.isCanGetPrime()
            self.payButton.alpha = (status.isCanGetPrime()) ? 1.0 : 0.25
        }
        self.payButton.isEnabled = false
        self.payButton.alpha = 0.25
    }
    
    @IBAction func payButton(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "付款成功", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(ok)
        
        self.tpdCard.onSuccessCallback { (prime, cardInfo) in
            self.present(alert, animated: true, completion: nil)
            
            print("Prime : \(prime!), LastFour : \(cardInfo!.lastFour!) , ")
            print("Bincode : \(cardInfo?.bincode!), Issuer : \(cardInfo?.issuer!), cardType : \(cardInfo!.cardType), funding : \(cardInfo?.funding) ,country : \(cardInfo?.country!) , countryCode : \(cardInfo?.countryCode!) , level : \(cardInfo?.level!)")
            }.onFailureCallback { (status, message) in
                print("status : \(status) , Message : \(message)")
            }.getPrime()
    }
}
