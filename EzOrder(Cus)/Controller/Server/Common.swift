//
//  Common.swift
//  TestServerDemo
//
//  Created by Lee Chien Kuan on 2019/6/5.
//  Copyright © 2019 Lee Chien Kuan. All rights reserved.
//

import Foundation
import UIKit

// 實機
// let common_url = "http://192.168.0.101:8080/Spot_MySQL_Web/"
// 模擬器
let common_url = "http://127.0.0.1:8080/TestServerDemo/"

func executeTask(_ url_server: URL, _ requestParam: [String: String], completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
    // 將輸出資料列印出來除錯用
    print("output: \(requestParam)")
    
    let jsonData = try! JSONEncoder().encode(requestParam)
    var request = URLRequest(url: url_server)
    request.httpMethod = "POST"
    request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
    request.httpBody = jsonData
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: completionHandler)
    task.resume()
}

func showSimpleAlert(message: String, viewController: UIViewController) {
    let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
    let cancel = UIAlertAction(title: "Cancel", style: .cancel)
    alertController.addAction(cancel)
    /* 呼叫present()才會跳出Alert Controller */
    viewController.present(alertController, animated: true, completion:nil)
}

func findByAccount() {
let requestParam = ["action" : "findByAccount", "account": "memberAccount1"]
    executeTask(url_server!, requestParam) { (data, response, error) in
        if error == nil {
            if data != nil {
                // 將輸入資料列印出來除錯用
                print("input: \(String(data: data!, encoding: .utf8)!)")
                
                if let result = try? JSONSerialization.jsonObject(with: data!){
                    self.userInfo = result as! [String : Any]
                    User.shared.account = (self.userInfo["account"] as! String)
                    User.shared.name = (self.userInfo["name"] as! String)
                    User.shared.age  = (self.userInfo["age"] as! Int)
                    User.shared.gender = (self.userInfo["gender"] as! Int)
                    User.shared.point = (self.userInfo["point"] as! Int)
                    User.shared.spinChance = (self.userInfo["spinChance"] as! Int)
                    User.shared.tel = (self.userInfo["tel"] as! String)
                    DispatchQueue.main.async {
                        self.nameLabel.text = "姓名：" + User.shared.name!
                        self.telLabel.text = "電話：" + (User.shared.tel ?? "尚未輸入")
                        self.pointLabel.text = "點數：" + String(User.shared.point ) + "點"
                    }
                }
            }
        } else {
            print("Error: " + error!.localizedDescription)
        }
    }
}
var userInfo = [String: Any]()
let url_server = URL(string: common_url + "MemberServlet")
