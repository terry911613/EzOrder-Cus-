//
//  EditPersonalViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/6/5.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class EditPersonalViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameTextfield: UITextField!
    @IBOutlet weak var userPhoneTextfield: UITextField!
    @IBOutlet weak var alertView: UIView!
    
    @IBAction func tapEditPersonal(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController,animated: true)
    }
    var viewHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardObserver()
    }
    
    
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func doneButton(_ sender: UIButton) {
        upload()
        dismiss(animated: true, completion: nil)
    }
    func upload(){
        
        let db = Firestore.firestore()
        
        if let userID = Auth.auth().currentUser?.email,
            let userImage = userImageView.image,
            let userName = userNameTextfield.text, userName.isEmpty == false,
            let userPhone = userPhoneTextfield.text, userPhone.isEmpty == false{
            //DocumentReference 指定位置
            //照片參照
            SVProgressHUD.show()
            let storageReference = Storage.storage().reference()
            let fileReference = storageReference.child(UUID().uuidString + ".jpg")
            let size = CGSize(width: 640, height: userImage.size.height * 640 / userImage.size.width)
            UIGraphicsBeginImageContext(size)
            userImage.draw(in: CGRect(origin: .zero, size: size))
            let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let data = resizeImage?.jpegData(compressionQuality: 0.8){
                fileReference.putData(data,metadata: nil) {(metadate, error) in
                    guard let _ = metadate, error == nil else {
                        SVProgressHUD.dismiss()
                        self.errorAlert()
                        return
                    }
                    fileReference.downloadURL(completion: { (url, error) in
                        guard let downloadURL = url else {
                            SVProgressHUD.dismiss()
                            self.errorAlert()
                            return
                        }
                        let data: [String: Any] = ["userImage": downloadURL.absoluteString,
                                                   "userName": userName,
                                                   "userPhone": userPhone]
                        db.collection("user").document(userID).updateData(data, completion: { (error) in
                            guard error == nil else {
                                SVProgressHUD.dismiss()
                                self.errorAlert()
                                return
                            }
                            SVProgressHUD.dismiss()
                            let alert = UIAlertController(title: "上傳完成", message: nil, preferredStyle: .alert)
                            let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
                            alert.addAction(ok)
                            self.present(alert, animated: true, completion: nil)
                        })
                        SVProgressHUD.dismiss()
                    })
                }
            }
        }
        else{
            let alert = UIAlertController(title: "請填寫完整", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        
//        personalImageView.startAnimating()
//        let nameTextfields = nameTextfield.text ?? ""
//        let phoneTextfields = phoneTextfield.text ?? ""
//        let db = Firestore.firestore()
//        let dats: [String:Any] = ["Name" : nameTextfields,"Phone" : phoneTextfields]
//        var photoReference : DocumentReference?
//        photoReference =  db.collection("personal").addDocument(data: dats) { (error) in
//            guard error == nil  else {
//                self.personalImageView.startAnimating()
//                return
//            }
//            let storageReference = Storage.storage().reference()
//            let fileReference = storageReference.child(UUID().uuidString + ".jpg")
//            let image = self.personalImageView.image
//            let size = CGSize(width: 640, height:
//                image!.size.height * 640 / image!.size.width)
//            UIGraphicsBeginImageContext(size)
//            image?.draw(in: CGRect(origin: .zero, size: size))
//            let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            if let data = resizeImage?.jpegData(compressionQuality: 0.8)
//            { fileReference.putData(data,metadata: nil) {(metadate , error) in
//                guard let _ = metadate, error == nil else {
//                    self.personalImageView.stopAnimating()
//                    return
//                }
//                fileReference.downloadURL(completion: { (url, error) in
//                    guard let downloadURL = url else {
//                        self.personalImageView.stopAnimating()
//                        return
//                    }
//                    photoReference?.updateData(["photoUrl": downloadURL.absoluteString])
//                }
//
//                )}
//
//
//            }
//
//        }
        
    }
    func errorAlert(){
        let alert = UIAlertController(title: "上傳失敗", message: "請稍後再試一次", preferredStyle: .alert)
        let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
extension EditPersonalViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let select = info[.originalImage] as? UIImage
        userImageView.image = select
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
extension EditPersonalViewController {
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        // 能取得鍵盤高度就讓view上移鍵盤高度，否則上移view的1/3高度
        viewHeight = view.frame.height
        let alertViewHeight = self.alertView.frame.height
        let alertViewLeftBottomY = alertView.frame.origin.y + alertViewHeight
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            
            let overlap = alertViewLeftBottomY + keyboardRect.height - viewHeight!
            if overlap > -10 {
                    self.alertView.frame.origin.y -= (overlap + 10)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
            self.alertView.center = self.view.center
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
