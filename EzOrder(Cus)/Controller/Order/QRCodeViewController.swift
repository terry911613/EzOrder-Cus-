//
//  OrderViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/15.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // 預覽時管理擷取影像的物件
    var captureSession: AVCaptureSession!
    // 預覽畫面
    var previewLayer: AVCaptureVideoPreviewLayer!
    // 偵測到QR code時需要加框
    var qrFrameView: UIView!
    // 當user決定加好友時呼叫
    var table = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        startPreviewAndScanQR()
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
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 將取得的資訊轉成條碼資訊
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            guard let qrString = metadataObject.stringValue else { return }
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            table = qrString
            scanSuccess(qrCode: qrString)
            if let barCodeObject = previewLayer.transformedMetadataObject(for: metadataObject) {
                // 成功解析就將QR code圖片框起來
                qrFrameView.frame = barCodeObject.bounds
            }
        } else {
            // 無法轉成條碼資訊就將圖框隱藏
            qrFrameView.frame = CGRect.zero
        }
    }
    
    func scanSuccess(qrCode: String) {
        print(qrCode)
        // 停止預覽
        preview(false)
        order(name: qrCode)
    }
    
    func order(name: String) {
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
            orderVC.table = table
        }
        
    }
}
