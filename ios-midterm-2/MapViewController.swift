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
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // used to show user's current location
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        setupViews()
        
        setPinsAndOverlays()
    }
    
    func setPinsAndOverlays() {
        for location in tempLocations {
            let latitude = location.value[0]
            let longitude = location.value[1]
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            map.addAnnotation(annotation)
            
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            // FIXME: each location should have it's own radius? or we can have square overlays. to compensate for different lot/location sizes.
            let radius = CLLocationDistance(70)
            let circle = MKCircle(center: center, radius: radius)
            map.addOverlay(circle)
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
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
        map.delegate = self
        return map
    }()
    
    func setupMap() {
        map.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        map.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circelOverLay = overlay as? MKCircle else {return MKOverlayRenderer()}
        
        let circleRenderer = MKCircleRenderer(circle: circelOverLay)
        circleRenderer.strokeColor = .blue
        circleRenderer.fillColor = .blue
        circleRenderer.alpha = 0.2
        return circleRenderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
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

// source for creating mkcircle overlay: https://stackoverflow.com/questions/33293075/how-to-create-mkcircle-in-swift
// source for getting user's current location: https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
// source for updating current location: https://stackoverflow.com/questions/25449469/show-current-location-and-update-location-in-mkmapview-in-swift
