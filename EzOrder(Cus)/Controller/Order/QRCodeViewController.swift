//
//  OrderViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/15.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // 預覽時管理擷取影像的物件
    var captureSession: AVCaptureSession!
    // 預覽畫面
    var previewLayer: AVCaptureVideoPreviewLayer!
    // 偵測到QR code時需要加框
    var qrFrameView: UIView!
    // 當user決定加好友時呼叫
    var tableNo: Int?
    var resID: String?
    var orderNo: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email {
            db.collection("user").document(userID).collection("order").whereField("payStatus", isEqualTo: 0).getDocuments { (querySnapShot, error) in
                if let result = querySnapShot?.documents {
                    if result.isEmpty {
                        self.startPreviewAndScanQR()
                    } else {
                        self.tableNo = (result[0].data()["tableNo"] as! Int)
                        self.resID = (result[0].data()["resID"] as! String)
                        self.orderNo = (result[0].data()["orderNo"] as! String)
                        self.performSegue(withIdentifier: "menuSegue", sender: self)
                    }
                } else {
                    self.startPreviewAndScanQR()
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        preview(false)
    }

    func startPreviewAndScanQR() {
        // 管理影像擷取期間的輸入與輸出
        captureSession = AVCaptureSession()
        // 負責擷取影像的預設裝置
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        // 建立輸入物件
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        if (captureSession.canAddInput(input)) {
            // 設定擷取期間的輸入
            captureSession.addInput(input)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            // 設定擷取期間的輸出
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // 欲處理的類型為QR code
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        // 建立擷取期間所需顯示的預覽圖層
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // 建立QR code掃描框
        qrFrameView = UIView()
        qrFrameView.layer.borderColor = UIColor.yellow.cgColor
        qrFrameView.layer.borderWidth = 3
        view.addSubview(qrFrameView)
        view.bringSubviewToFront(qrFrameView)
        
        preview(true)
    }
    
    func failed() {
        let alert = UIAlertController(title: "掃描失敗", message: "請再試一次", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
        captureSession = nil
    }
    
    // 是否開啟預覽畫面
    func preview(_ yes: Bool) {
        if yes {
            // 讓QR code掃描框消失 (避免前一次QR code掃描框留在畫面上)
            qrFrameView.frame = CGRect.zero
            if (captureSession?.isRunning == false) {
                captureSession.startRunning()
            }
        } else {
            if (captureSession?.isRunning == true) {
                captureSession.stopRunning()
            }
        }
    }
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 將取得的資訊轉成條碼資訊
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            guard let qrString = metadataObject.stringValue else { return }
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            if let qrData = qrString.data(using: .utf8){
                let result = try! JSONDecoder().decode([String: String].self, from: qrData)
                if let table = Int(result["table"]!),
                    let resID = result["resID"]{
                    self.tableNo = table
                    self.resID = resID
                    scanSuccess(qrCode: table)
                }
            }
           
            if let barCodeObject = previewLayer.transformedMetadataObject(for: metadataObject) {
                // 成功解析就將QR code圖片框起來
                qrFrameView.frame = barCodeObject.bounds
            }
        } else {
            // 無法轉成條碼資訊就將圖框隱藏
            qrFrameView.frame = CGRect.zero
        }
    }
    
    func scanSuccess(qrCode: Int) {
        // 停止預覽
        preview(false)
        order(name: qrCode)
    }
    
    func order(name: Int) {
        let alert = UIAlertController(title: "\(name)桌點餐?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "menuSegue", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            self.preview(true)
        }))
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "menuSegue"{
            let orderVC = segue.destination as! OrderViewController
            if let tableNo = tableNo, let resID = resID{
                orderVC.tableNo = tableNo
                orderVC.resID = resID
                if let orderNo = self.orderNo {
                    orderVC.orderNo = orderNo
                }
            }
        }
        
    }
}
