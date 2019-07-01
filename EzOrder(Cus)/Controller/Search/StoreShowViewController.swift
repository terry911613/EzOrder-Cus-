//
//  StoreShowViewController.swift
//  EzOrder(Cus)
//
//  Created by 劉十六 on 2019/6/6.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import Kingfisher

class StoreShowViewController: UIViewController,CLLocationManagerDelegate{
    
    @IBOutlet weak var backgroundScrollView: UIScrollView!
    @IBOutlet weak var showClassificationCollectionView: UICollectionView!
    @IBOutlet weak var showStoreImageView: UIImageView!
    @IBOutlet weak var showStoreNameLabel: UILabel!
    @IBOutlet weak var showStoreOpenTimeLabel: UILabel!
    @IBOutlet weak var showStorePhoneLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var textImageview: UIImageView!
    @IBOutlet var textimage2: [UIImageView]!
    @IBOutlet weak var showAddressButton: UIButton!
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var rateView: UIImageView!
    @IBOutlet weak var resCommentTableView: UITableView!
    var searcbool =  false
    var res: DocumentSnapshot?
    var favRes: DocumentSnapshot?
    var enterFromFavorite = false
    var resID: String?
    var resName: String?
    var resCommentArray = [QueryDocumentSnapshot]()
    var DocumentID : String?
    var clickButton = false
    let geoCoder = CLGeocoder()
    var location: CLLocation?
    var locations:CLLocationManager!
    var coordinates: CLLocationCoordinate2D?
    var nowLocations: CLLocationCoordinate2D?
    
    var typeArray = [QueryDocumentSnapshot]()
    var beginningHandler: ()?
    
    deinit {
        print("storeShow deinit")
        print("storeShow deinit")
        print("storeShow deinit")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadProcess()
    }
    override func viewWillAppear(_ animated: Bool) {
        if let beginningHandler = beginningHandler {
            beginningHandler
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        enterFromFavorite = false
        if beginningHandler != nil {
            beginningHandler = nil
        }
        
    }
    func viewDidLoadProcess() {
        likeButton.setImage(UIImage(named: "link"), for: .normal)
        
        func generalProcess() {
            
            let db = Firestore.firestore()
            if searcbool{
                if let DocumentID = DocumentID {
                    print("1234589",DocumentID)
                    if
                        let userID = Auth.auth().currentUser?.email{
                        db.collection("res").document(DocumentID).collection("foodType").order(by: "index", descending: false).getDocuments { (type, error) in
                            if let type = type{
                                if type.documents.isEmpty{
                                    self.typeArray.removeAll()
                                    self.showClassificationCollectionView.reloadData()
                                }
                                else{
                                    self.typeArray = type.documents
                                    self.showClassificationCollectionView.reloadData()
                                }
                            }
                        }
                        
                        db.collection("user").document(userID).collection("favoriteRes").getDocuments { (favoriteRes, error) in
                            if let favoriteRes = favoriteRes{
                                if favoriteRes.documents.isEmpty == false{
                                    for favoriteRes in favoriteRes.documents{
                                        if let resID = favoriteRes.data()["resID"] as? String{
                                            if DocumentID == resID{
                                                self.likeButton.setImage(UIImage(named: "donut"), for: .normal)
                                                self.clickButton = true
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    db.collection("res").document(DocumentID).getDocument{(resData,error) in
                        if let resData = resData{
                            if let resImage = resData["resImage"] as? String,
                                let resName = resData["resName"] as? String,
                                let resTel = resData["resTel"] as? String,
                                let resLocation = resData["resLocation"] as? String,
                                let resID = resData["resID"] as? String,let resTime = resData["resTime"] as? String{
                                self.showStoreOpenTimeLabel.text = resTime
                                self.showStoreImageView.kf.setImage(with: URL(string: resImage))
                                self.showStoreNameLabel.text = resName
                                self.showAddressButton.setTitle(resLocation, for: .normal)
                                self.showStorePhoneLabel.text = resTel
                                self.resName = resName
                                self.resID = resID
                                self.locations = CLLocationManager()
                                self.locations.delegate = self
                                self.locations.requestWhenInUseAuthorization()
                                self.locations.startUpdatingLocation()
                                self.setMapRegion()
                                self.showAddressButton.resignFirstResponder()
                                let text = self.showAddressButton.title(for: .normal)
                                let geocoder = CLGeocoder()
                                if let text = text {
                                    geocoder.geocodeAddressString(text) { (placemarks, error) in
                                        if error == nil && placemarks != nil && placemarks!.count > 0 {
                                            if let placemark = placemarks!.first {
                                                let location = placemark.location!
                                                self.setMapCenter(center: location.coordinate)
                                                self.setMapAnnotation(location)
                                            }
                                        } else {
                                            let title = "收尋失敗"
                                            let message = "目前網路連線不穩定"
                                            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                                            let ok = UIAlertAction(title: "OK", style: .default)
                                            alertController.addAction(ok)
                                            self.present(alertController, animated: true, completion: nil)
                                        }
                                    }
                                    
                                    
                                }
                                
                                
                                let db = Firestore.firestore()
                                db.collection("res").document(resID).collection("resComment").order(by: "date", descending: true).getDocuments { (comment, error) in
                                    if let comment = comment{
                                        if comment.documents.isEmpty{
                                            self.resCommentArray.removeAll()
                                            self.resCommentTableView.reloadData()
                                        }
                                        else{
                                            self.resCommentArray = comment.documents
                                            self.resCommentTableView.reloadData()
                                        }
                                    }
                                }
                            }
                            
                            if let resTotalRate = resData["resTotalRate"] as? Float,
                                let resRateCount = resData["resRateCount"] as? Float{
                                
                                if resRateCount == 0{
                                    self.updateStar(value: 0, image: self.rateView)
                                }
                                else{
                                    self.updateStar(value: resTotalRate/resRateCount, image: self.rateView)
                                }
                            }
                        }
                        
                    }
                    
                }
            }
            else  {
                if let res = res,
                    let userID = Auth.auth().currentUser?.email{
                    db.collection("res").document(res.documentID).collection("foodType").order(by: "index", descending: false).getDocuments { (type, error) in
                        if let type = type{
                            if type.documents.isEmpty{
                                self.typeArray.removeAll()
                                self.showClassificationCollectionView.reloadData()
                            }
                            else{
                                self.typeArray = type.documents
                                self.showClassificationCollectionView.reloadData()
                            }
                        }
                    }
                    
                    db.collection("user").document(userID).collection("favoriteRes").getDocuments { (favoriteRes, error) in
                        if let favoriteRes = favoriteRes{
                            if favoriteRes.documents.isEmpty == false{
                                for favoriteRes in favoriteRes.documents{
                                    if let resID = favoriteRes.data()["resID"] as? String{
                                        if res.documentID == resID{
                                            self.likeButton.setImage(UIImage(named: "donut"), for: .normal)
                                            self.clickButton = true
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if let resData = res.data(){
                        if let resImage = resData["resImage"] as? String,
                            let resName = resData["resName"] as? String,
                            let resTel = resData["resTel"] as? String,
                            let resLocation = resData["resLocation"] as? String,
                            let resID = resData["resID"] as? String,let resTime = resData["resTime"] as? String{
                            self.showStoreOpenTimeLabel.text = resTime
                            self.showStoreImageView.kf.setImage(with: URL(string: resImage))
                            self.showStoreNameLabel.text = resName
                            self.showAddressButton.setTitle(resLocation, for: .normal)
                            self.showStorePhoneLabel.text = resTel
                            self.resName = resName
                            self.resID = resID
                            searcbool = false
                            
                            let db = Firestore.firestore()
                            db.collection("res").document(resID).collection("resComment").order(by: "date", descending: true).getDocuments { (comment, error) in
                                if let comment = comment{
                                    if comment.documents.isEmpty{
                                        self.resCommentArray.removeAll()
                                        self.resCommentTableView.reloadData()
                                    }
                                    else{
                                        self.resCommentArray = comment.documents
                                        self.resCommentTableView.reloadData()
                                    }
                                }
                            }
                        }
                        
                        if let resTotalRate = resData["resTotalRate"] as? Float,
                            let resRateCount = resData["resRateCount"] as? Float{
                            
                            if resRateCount == 0{
                                self.updateStar(value: 0, image: self.rateView)
                            }
                            else{
                                self.updateStar(value: resTotalRate/resRateCount, image: self.rateView)
                            }
                        }
                    }
                }
                
                
            }
            
            self.locations = CLLocationManager()
            self.locations.delegate = self
            self.locations.requestWhenInUseAuthorization()
            self.locations.startUpdatingLocation()
            setMapRegion()
            showAddressButton.resignFirstResponder()
            let text = showAddressButton.title(for: .normal)
            let geocoder = CLGeocoder()
            if let text = text {
                geocoder.geocodeAddressString(text) { (placemarks, error) in
                    if error == nil && placemarks != nil && placemarks!.count > 0 {
                        if let placemark = placemarks!.first {
                            let location = placemark.location!
                            self.setMapCenter(center: location.coordinate)
                            self.setMapAnnotation(location)
                        }
                    } else {
                        let title = "收尋失敗"
                        let message = "目前網路連線不穩定"
                        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default)
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                
                
            }
        }
        if enterFromFavorite {
            if let favResData = favRes?.data(),
                let resID = favResData["resID"] as? String{
                self.resID = resID
                let db = Firestore.firestore()
                db.collection("res").document(resID).getDocument { (res, error) in
                    if let res = res{
                        self.res = res
                        generalProcess()
                    }
                }
            } else {
                let db = Firestore.firestore()
                if let resID = resID {
                    db.collection("res").document(resID).getDocument { (res, error) in
                        if let res = res{
                            self.res = res
                            generalProcess()
                        }
                    }
                }
            }
        } else {
            generalProcess()
        }
    }
    
    @IBAction func myMapButton(_ sender: Any) {
        showAddressButton.resignFirstResponder()
        let text = showAddressButton.title(for: .normal)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(text!) { (placemarks, error) in
            if error == nil && placemarks != nil && placemarks!.count > 0 {
                if let placemark = placemarks!.first {
                    let nowLocation = self.nowLocations
                    let airstation =  self.coordinates
                    let Pa = MKPlacemark(coordinate: nowLocation!,addressDictionary: nil)
                    let Pb = MKPlacemark(coordinate: airstation!,addressDictionary: nil)
                    let miA = MKMapItem(placemark: Pa)
                    let mib = MKMapItem(placemark: Pb)
                    miA.name = "我的位置"
                    mib.name = self.showStoreNameLabel.text
                    let routes = [miA,mib]
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    MKMapItem.openMaps(with: routes, launchOptions: options)
                    
                    let location = placemark.location!
                    self.setMapCenter(center: location.coordinate)
                }
            } else {
                let title = "收尋失敗"
                let message = "目前網路連線不穩定"
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    
    @IBAction func likeButtonAction(_ sender: UIButton) {
        // to nil 就轉成window座標系
        let btnLocation = (sender.superview?.convert(sender.frame.origin, to: nil))!
        let image = UIImage(named: "donut")
        let imageViews = UIImageView(image: image!)
        imageViews.frame = CGRect(origin: btnLocation, size: CGSize(width: 41, height: 50))
        view.addSubview(imageViews)
        textimage2.insert(imageViews, at: 0)
        clickButton = !clickButton
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email,
            let resID = res?.documentID{
            
            if clickButton{
                likeButton.setImage(UIImage(named: "donut"), for: .normal)
                UIView.animate(withDuration: 1.5 , delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.textimage2[0].frame = CGRect(x:btnLocation.x-177 , y: btnLocation.y-145, width: self.textimage2[0].frame.size.width * 2, height: self.textimage2[0].frame.size.height * 2)
                    imageViews.alpha = 0.7
                }, completion: {Result -> Void in
                    imageViews.removeFromSuperview()
                })
                if searcbool == true {
                    if let DocumentID = DocumentID {
                        print("1234589",DocumentID)
                        db.collection("user").document(userID).collection("favoriteRes").document(DocumentID).setData(["resID": DocumentID])
                        
                    }
                }
                else
                {
                    db.collection("user").document(userID).collection("favoriteRes").document(resID).setData(["resID": resID])
                }
                
            }
            else {
                if searcbool == true {
                    if let DocumentID = DocumentID {
                        db.collection("user").document(userID).collection("favoriteRes").document(DocumentID).delete()
                        likeButton.setImage(UIImage(named: "link"), for: .normal)
                        imageViews.isHidden = true
                        
                    }
                }
                
                db.collection("user").document(userID).collection("favoriteRes").document(resID).delete()
                likeButton.setImage(UIImage(named: "link"), for: .normal)
                imageViews.isHidden = true
                
            }
            
        }
        
        
    }
    func setMapCenter(center: CLLocationCoordinate2D) {
        myMap.setCenter(center, animated: true)
        
    }
    
    func setMapAnnotation(_ location: CLLocation) {
        let text = showAddressButton.title(for: .normal)
        let coordinate = location.coordinate
        let annotation = MKPointAnnotation()
        self.coordinates = coordinate
        annotation.coordinate = coordinate
        annotation.title = text
        annotation.subtitle = "(\(coordinate.latitude), \(coordinate.longitude))"
        myMap.addAnnotation(annotation)
        
    }
    func setMapRegion() {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        var region = MKCoordinateRegion()
        region.span = span
        myMap.setRegion(region, animated: true)
        myMap.regionThatFits(region)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let c = locations[0] as CLLocation
        let nowLocation = CLLocationCoordinate2D(latitude: c.coordinate.latitude, longitude: c.coordinate.longitude)
        self.nowLocations = nowLocation
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "menuSegue"{
            let searchMenuVC = segue.destination as! SearchMenuViewController
            searchMenuVC.typeArray = typeArray
            if searcbool == true {
                searchMenuVC.searchbool = true
                searchMenuVC.DocumentID = DocumentID
            }
            else {
                if let resID = res?.documentID{
                    searchMenuVC.resID = resID
                    searchMenuVC.searchbool = false
                }
            }
            
        }
        if segue.identifier == "bookSegue"{
            let bookingVC = segue.destination as! BookingViewController
            if let resID = resID,
                let resName = resName{
                if searcbool == true {
                    bookingVC.searchbool = true
                    bookingVC.DocumnetID = DocumentID
                    bookingVC.resName = resName
                    
                }else {
                    bookingVC.searchbool = false
                    bookingVC.resID = resID
                    bookingVC.resName = resName
                }
            }
        }
    }
    func updateStar(value: Float, image: UIImageView) {
        let rate = value
        if rate < 2.75 {
            if rate < 0.25 {
                image.image = UIImage(named: "rate0")
            } else if rate < 0.75 {
                image.image = UIImage(named: "rate05")
            } else if rate < 1.25 {
                image.image = UIImage(named: "rate1")
            } else if rate < 1.75 {
                image.image = UIImage(named: "rate15")
            } else if rate < 2.25 {
                image.image = UIImage(named: "rate2")
            } else {
                image.image = UIImage(named: "rate25")
            }
        } else {
            if rate < 3.25 {
                image.image = UIImage(named: "rate3")
            } else if rate < 3.75 {
                image.image = UIImage(named: "rate35")
            } else if rate < 4.25 {
                image.image = UIImage(named: "rate4")
            } else if rate < 4.75 {
                image.image = UIImage(named: "rate45")
            } else {
                image.image = UIImage(named: "rate5")
            }
        }
    }
    
    @IBAction func unwindSegueStoreShow(segue: UIStoryboardSegue){
    }
}

extension StoreShowViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MuneCell", for: indexPath) as! StoreShowCollectionViewCell
        
        let type = typeArray[indexPath.row]
        
        if let typeName = type.data()["typeName"] as? String,
            let typeImage = type.data()["typeImage"] as? String{
            cell.showClassificationName.text = typeName
            cell.showStoresImageView.kf.setImage(with: URL(string: typeImage))
        }
        return cell
    }
}

extension StoreShowViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resCommentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resCommentCell", for: indexPath) as! ResCommentTableViewCell
        let comment = resCommentArray[indexPath.row]
        if let userID = comment.data()["userID"] as? String,
            let resRate = comment.data()["resRate"] as? Float,
            let resComment = comment.data()["resComment"] as? String{
            
            let db = Firestore.firestore()
            db.collection("user").document(userID).getDocument { (user, error) in
                if let userData = user?.data(){
                    if let userImage = userData["userImage"] as? String{
                        cell.userImageView.kf.setImage(with: URL(string: userImage))
                    }
                }
            }
            updateStar(value: resRate, image: cell.rateView)
            cell.commentTextView.text = resComment
        }
        
        return cell
    }
}
