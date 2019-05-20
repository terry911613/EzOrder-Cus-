//
//  ProgressViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/15.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {
    
    @IBOutlet weak var totalMoneyLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    
    var igcMenu: IGCMenu?
    var isMenuActive = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMenu()
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
                self.payButton.setTitle("付款", for: .normal)
                self.payButton.setTitleColor(.white, for: .normal)
                self.igcMenu?.hideCircularMenu()
                self.isMenuActive = false
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        else{
            //            menuButton.setImage(UIImage(named: "Pay"), for: .normal)
            payButton.setTitle("付款", for: .normal)
            payButton.setTitleColor(.white, for: .normal)
            self.igcMenu?.hideCircularMenu()
            self.isMenuActive = false
        }
    }
}
