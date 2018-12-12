//
//  map2vc.swift
//  ios-midterm-2
//
//  Created by Jordan George on 12/4/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import MapKit

class AdminMapViewController: UIViewController {
    
    // MARK: - properties
    
    let locationManager = CLLocationManager()
    var coords = [String: Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // creates and positions map
        view.addSubview(map)
        setUpMap()
        
        // gets users current location
        configureLocationManager()
        
        // recognize long press
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(addPin(gesture:)))
        uilpgr.minimumPressDuration = 1.0
        map.addGestureRecognizer(uilpgr)
    }
    
    // add a pin where the user long pressed
    @objc func addPin(gesture: UILongPressGestureRecognizer) {
        map.removeAnnotations(map.annotations)
        
        let location = gesture.location(in: map)
        let coords = map.convert(location, toCoordinateFrom: map)
        
        setCoords(coordinates: coords)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coords
        annotation.title = "New parking spot"
        map.addAnnotation(annotation)
    }
    
    // set coordinates to be added to firebase
    func setCoords(coordinates: CLLocationCoordinate2D) {
        coords = [
            "lat": coordinates.latitude,
            "lon": coordinates.longitude
        ]
        UserDefaults.standard.set(coords, forKey: "coords")
    }
    
    // for locating the user
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - views
    
    // create map
    lazy var map: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    // positions map
    func setUpMap() {
        map.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        map.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
}

// gets user's current location
extension AdminMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.map.setRegion(region, animated: true)
            
            locationManager.stopUpdatingLocation()
            map.showsUserLocation = true
        }
    }
}
