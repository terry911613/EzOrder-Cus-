//
//  SearcMapViewController.swift
//  EzOrder(Cus)
//
//  Created by 劉十六 on 2019/6/8.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import MapKit
class SearcMapViewController: UIViewController {
    var location: CLLocation?
    @IBOutlet weak var MapView: MKMapView!
    
    override func viewDidLoad() {
        setMapRegion()
        MapView.mapType = .standard

        let yangmingshan = CLLocationCoordinate2D(latitude: 25.155790, longitude: 121.547742)
        MapView.setCenter(yangmingshan, animated: true)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func setMapRegion() {
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        var region = MKCoordinateRegion()
        region.span = span
        MapView.setRegion(region, animated: true)
        MapView.regionThatFits(region)
    }

}
