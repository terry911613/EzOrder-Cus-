
import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import SVProgressHUD

var text = true
class SignInViewController: UIViewController, LoginButtonDelegate{
    
    @IBOutlet weak var signInButton: FBLoginButton!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.delegate = self
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "loginToEzOrderSegue", sender: self)
            }
        }
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {

        if error == nil {
            let credential = FacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.tokenString ?? ""))
            Auth.auth().signIn(with:credential){
                (authresult,error) in

                if let error = error {
                    text = false
                    print(text)
                    if text == false {
                        self.dismiss(animated: true)
                        print(1)

                    }
                    print(error.localizedDescription)
                    print(2)
                    return
                }
            }

        }
        else {
            print(3)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        text = false
        if text == false {
            dismiss(animated: true)
            print("登出")
        }
    }
    
    @IBAction func logInButton(_ sender: UIButton) {
        
        SVProgressHUD.show()
        //TODO: Log in the user
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil {
                print(error!)
                print("ffffffffuuuuuuuuucccccccckkkkkkkkkkk")
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "登入失敗", message: error?.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                print("Log in Successful")
                print("ffffffffuuuuuuuuucccccccckkkkkkkkkkk")
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "loginToEzOrderSegue", sender: self)
            }
        }
    }
    //  隨便按一個地方，彈出鍵盤就會收回
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func unwindSegueBackLogin(segue: UIStoryboardSegue){
    }
}
