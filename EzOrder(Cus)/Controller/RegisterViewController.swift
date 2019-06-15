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
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    var fuckGitHub: String?
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func registerButton(_ sender: UIButton) {
        
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil {
                print("--------------")
                print(error!)
                print("--------------")
                SVProgressHUD.dismiss()
                self.emailLabel.text = "請輸入正確格式"
                self.emailLabel.textColor = .red
                self.emailLabel.isHidden = false
                self.passwordLabel.text = "請輸入6～12位數"
                self.passwordLabel.textColor = .red
                self.passwordLabel.isHidden = false
                let alert = UIAlertController(title: "註冊失敗", message: error?.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.emailLabel.text = ""
                self.emailLabel.isHidden = true
                self.passwordLabel.text = ""
                self.passwordLabel.isHidden = true
                
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


