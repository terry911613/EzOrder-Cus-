
import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import SVProgressHUD

var text = true
class SignInViewController: UIViewController, LoginButtonDelegate{
    
    @IBOutlet weak var btnStackView: UIStackView!
    @IBOutlet weak var signInButton: FBLoginButton!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    var viewHeight: CGFloat?
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardObserver()
        emailTextfield.text = ""
        passwordTextfield.text = ""
    }
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
                
                let db = Firestore.firestore()
                if let userID = Auth.auth().currentUser?.email{
                    db.collection("user").document(userID).setData(["userID": userID,
                                                                    "pointCount": 0,
                                                                    "totalPoint": 0])
                }
                
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
                self.emailLabel.text = "帳號錯誤"
                self.emailLabel.textColor = .red
                self.emailLabel.isHidden = false
                self.passwordLabel.text = "密碼錯誤"
                self.passwordLabel.textColor = .red
                self.passwordLabel.isHidden = false
                print(error!)
                print("ffffffffuuuuuuuuucccccccckkkkkkkkkkk")
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "登入失敗", message: error?.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.emailLabel.text = ""
                self.emailLabel.isHidden = true
                self.passwordLabel.text = ""
                self.passwordLabel.isHidden = true

                
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

extension SignInViewController {
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        viewHeight = view.frame.height
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            let btnLocation = btnStackView.frame.origin
//                btnStackView.superview?.convert(btnStackView.frame.origin, to: view)
            print("location: ",btnLocation)
            let btnY = btnLocation.y
            let btnHeight = btnStackView.frame.height
            let overlap = btnY + btnHeight + keyboardRect.height - viewHeight!
            
            if overlap > 0 {
                view.frame.origin.y =  -(overlap + 5)
            }
            
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        view.frame.origin.y = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
