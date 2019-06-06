//
//  User.swift
//  EzOrder(Cus)
//
//  Created by Lee Chien Kuan on 2019/6/5.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import Foundation
class User {
    static let shared = User()
    var account: String!
    var password: String!
    var name: String?
    var point: Int! = 0
    var spinChance:Int! = 0
    var tel: String?
    var photo: Data?
    var age: Int?
    var gender: Int?
    
    private init() {}
}

//class UserObject: Codable {
//    var account: String
//    var password: String
//    var name: String?
//    var point: Int = 0
//    var spinChance: Int = 0
//    var tel: String?
//    var photo: Data?
//    var age: Int?
//    var gender: Int?
//    
//    public init(_ account: String, _ password: String, _ name: String, _ point: Int, _ spinChance: Int, _ tel: String, _ photo: Data, _ age: Int, _ gender: Int) {
//        self.account = account
//        self.password = password
//        self.name = name
//        self.point = point
//        self.spinChance = spinChance
//        self.tel = tel
//        self.photo = photo
//        self.age = age
//        self.gender = gender
//    }
//}
