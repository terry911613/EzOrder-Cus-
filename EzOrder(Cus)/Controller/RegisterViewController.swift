//
//  RegisterViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/6/8.
//  Copyright © 2019 TerryLee. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    var fuckGitHub: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func registerButton(_ sender: UIButton) {
        
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil {
                print(error!)
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "註冊失敗", message: error?.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                
                let db = Firestore.firestore()
                if let userID = Auth.auth().currentUser?.email{
                    db.collection("user").document(userID).setData(["userID": userID])
                }
                //  success
                print("Registration Successful!")
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "RegisterToEzOrderSegue", sender: self)
            }
            
        }
    }
    //  隨便按一個地方，彈出鍵盤就會收回
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


