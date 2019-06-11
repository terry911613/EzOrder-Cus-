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
    @IBOutlet weak var showLikeImageView: UIButton!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var textImageview: UIImageView!
    @IBOutlet var textimage2: [UIImageView]!
    @IBOutlet weak var showAddressButton: UIButton!
    @IBOutlet weak var myMap: MKMapView!
    
    var res: QueryDocumentSnapshot?
    
    var clickButton = true
    let geoCoder = CLGeocoder()
    var location: CLLocation?
    var locations:CLLocationManager!
    var coordinates: CLLocationCoordinate2D?
    var nowLocations: CLLocationCoordinate2D?
    var lise = ["1","2","3","4","5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let resData = res?.data(){
            if let resImage = resData["resImage"] as? String,
                let resName = resData["resName"] as? String,
                let resTel = resData["resTel"] as? String,
                let resLocation = resData["resLocation"] as? String{
                
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
        if clickButton == false{
        linkButton.setImage(UIImage(named: "donut"), for: .normal)
            UIView.animate(withDuration: 1.5 , delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.textimage2[0].frame = CGRect(x:btnLocation.x-177 , y: btnLocation.y-145, width: self.textimage2[0].frame.size.width * 2, height: self.textimage2[0].frame.size.height * 2)
                imageViews.alpha = 0.7
            }, completion: {Result -> Void in
                imageViews.removeFromSuperview()
                
            })
                    }
        if clickButton == true {
            linkButton.setImage(UIImage(named: "link"), for: .normal)
            imageViews.isHidden = true
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
}



extension StoreShowViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lise.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MuneCell", for: indexPath) as! StoreShowCollectionViewCell
      //  cell.showStoresImageView.image = UIImage(named: lise[indexPath.row])
        cell.showClassificationName.text = lise[indexPath.row]
        return cell
    }
    
    
}

