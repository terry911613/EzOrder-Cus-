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
    
    var res: QueryDocumentSnapshot?
    
    var clickButton = false
    let geoCoder = CLGeocoder()
    var location: CLLocation?
    var locations:CLLocationManager!
    var coordinates: CLLocationCoordinate2D?
    var nowLocations: CLLocationCoordinate2D?
    
    var typeArray = [QueryDocumentSnapshot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        likeButton.setImage(UIImage(named: "link"), for: .normal)
        
        if let res = res,
            let userID = Auth.auth().currentUser?.email{
            let db = Firestore.firestore()
            db.collection("res").document(res.documentID).collection("foodType").getDocuments { (type, error) in
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
                                    break
                                }
                            }
                        }
                    }
                }
            }
            
            if let resImage = res.data()["resImage"] as? String,
                let resName = res.data()["resName"] as? String,
                let resTel = res.data()["resTel"] as? String,
                let resLocation = res.data()["resLocation"] as? String{
                
                showStoreImageView.kf.setImage(with: URL(string: resImage))
                showStoreNameLabel.text = resName
                showAddressButton.setTitle(resLocation, for: .normal)
                showStorePhoneLabel.text = resTel
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
        geocoder.geocodeAddressString(text!) { (placemarks, error) in
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
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if let res = res{
//            if let resImage = res.data()["resImage"] as? String,
//                let resName = res.data()["resName"] as? String,
//                let resTel = res.data()["resTel"] as? String,
//                let resLocation = res.data()["resLocation"] as? String{
//                
//                showStoreImageView.kf.setImage(with: URL(string: resImage))
//                showStoreNameLabel.text = resName
//                showAddressButton.setTitle(resLocation, for: .normal)
//                showStorePhoneLabel.text = resTel
//            }
//        }
//    }
    
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
        let btnLocation = (sender.superview?.convert(sender.frame.origin, to: nil))!
        let image = UIImage(named: "donut")
        let imageViews = UIImageView(image: image!)
        imageViews.frame = CGRect(origin: btnLocation, size: CGSize(width: 30, height: 30))
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
                db.collection("user").document(userID).collection("favoriteRes").document(resID).setData(["resID": resID])
            }
            else {
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
        var text = showAddressButton.title(for: .normal)
        let coordinate = location.coordinate
        let annotation = MKPointAnnotation()
        self.coordinates = coordinate
        annotation.coordinate = coordinate
        annotation.title = text
        annotation.subtitle = "(\(coordinate.latitude), \(coordinate.longitude))"
        myMap.addAnnotation(annotation)
        
    }
    func setMapRegion() {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
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
            if let resID = res?.documentID{
                searchMenuVC.resID = resID
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

