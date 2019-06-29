class SearcArray {
    var name : String
    var image : String
    var resTotalRate : Float
    var resCount : Float
    var ID : String
    
    
    
    
    init(name:String,image:String,resTotalRate:Float,resCount: Float,ID:String){
        self.ID = ID
        self.name = name
        self.image = image
        self.resTotalRate = resTotalRate
        self.resCount = resCount

    }
    
    
//    Equatable
//    static func == (lhs: SearcArray, rhs: SearcArray) -> Bool {
//        return lhs.name == lhs.name
//    }

}
