
import UIKit
import FBSDKLoginKit
import Firebase
var text = true
class SignInFBViewController: UIViewController,LoginButtonDelegate{
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error == nil {
            let credential = FacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.tokenString ?? ""))
            Auth.auth().signInAndRetrieveData(with:credential){
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
    
    
    
    
    @IBOutlet weak var signInButton: FBLoginButton!
    
    override func viewDidLoad() {
        signInButton.delegate = self
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
}

