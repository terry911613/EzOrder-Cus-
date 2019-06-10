import Foundation

struct Restaurant: Codable {
    var storeName : String
    var storeEvaluation:  Double
    var storeImage : URL
    var storeAccount : Double
    var storePassword: Int
    var storeTel : Int
    var storePhone: Int
    var storeStatus: String
    var storeTexID: Int
    var storeBookingLimit : Int
    var storeCount : Int
    
}

struct Restaurants: Codable {
    var results : [Restaurant]
    
}


