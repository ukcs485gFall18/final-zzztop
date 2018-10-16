//
//  ViewController.swift
//  ios-midterm-2
//
//  Created by Jordan George on 10/13/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let tempLocations = [
        "rose street": [38.034140, -84.504062],
        "marksbury": [38.039970, -84.499179]
    ]
    let center = [38.030672, -84.504160]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        // set initial location to UK
        let initialLocation = CLLocation(latitude: center[0], longitude: center[1])
        centerMapOnLocation(location: initialLocation)
        
        setPins()
    }
   
    func setPins() {
        for location in tempLocations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.value[0], longitude: location.value[1])
            map.addAnnotation(annotation)
        }
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - views
    
    func setupViews() {
        view.addSubview(map)
        setupMap()
    }
    
    lazy var map: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    func setupMap() {
        map.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        map.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
}

