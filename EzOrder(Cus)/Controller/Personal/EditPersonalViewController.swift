//
//  EditPersonalViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/6/5.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
class EditPersonalViewController: UIViewController {

    @IBOutlet weak var personalImageView: UIImageView!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var phoneTextfield: UITextField!
    
    @IBAction func tapEditPersonal(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController,animated: true)    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func doneButton(_ sender: UIButton) {
        upload()
        dismiss(animated: true, completion: nil)
        
    }
    func upload()   {
        personalImageView.startAnimating()
        let nameTextfields = nameTextfield.text ?? ""
        let phoneTextfields = phoneTextfield.text ?? ""
        let db = Firestore.firestore()
        let dats: [String:Any] = ["Name" : nameTextfields,"Phone" : phoneTextfields]
        var photoReference : DocumentReference?
        photoReference =  db.collection("personal").addDocument(data: dats) { (error) in
            guard error == nil  else {
                self.personalImageView.startAnimating()
                return
            }
            let storageReference = Storage.storage().reference()
            let fileReference = storageReference.child(UUID().uuidString + ".jpg")
            let image = self.personalImageView.image
            let size = CGSize(width: 640, height:
                image!.size.height * 640 / image!.size.width)
            UIGraphicsBeginImageContext(size)
            image?.draw(in: CGRect(origin: .zero, size: size))
            let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let data = resizeImage?.jpegData(compressionQuality: 0.8)
            { fileReference.putData(data,metadata: nil) {(metadate , error) in
                guard let _ = metadate, error == nil else {
                    self.personalImageView.stopAnimating()
                    return
                }
                fileReference.downloadURL(completion: { (url, error) in
                    guard let downloadURL = url else {
                        self.personalImageView.stopAnimating()
                        return
                    }
                    photoReference?.updateData(["photoUrl": downloadURL.absoluteString])
                }
                    
                )}
                
                
            }
            
        }
        
    }
    
    
}
extension EditPersonalViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let select = info[.originalImage] as? UIImage
        personalImageView.image = select
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}

