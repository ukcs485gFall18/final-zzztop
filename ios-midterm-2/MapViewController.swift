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
    var pickerUIText = UITextField()
    var datePicker: UIDatePicker?
    
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
        
        createPickerView()
    }
    
    func createPickerView(){
        //create the UI text
        pickerUIText = UITextField(frame: CGRect(x: 50, y: 800, width: 300, height: 40))
        pickerUIText.text = "Please Select a Date"
        pickerUIText.textAlignment = NSTextAlignment.center
        pickerUIText.font = UIFont.systemFont(ofSize: 25)
        self.view.addSubview(pickerUIText)
        //create the DatePicker
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .dateAndTime
        datePicker?.addTarget(self, action: #selector(MapViewController.dateSelected(datePicker:)), for: .valueChanged)
        //add the DatePicker to the UITextField
        pickerUIText.inputView = datePicker
        //allow the user to get out of the date picker by tapping
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MapViewController.tapToLeave(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    //allows the user to leave the UI picker by tapping elsewhere
    @objc func tapToLeave(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    //Formats the date selected and places it into the UI Text Field
    @objc func dateSelected(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEEEEE MM/dd/yyyy hh:mm aaa"
        pickerUIText.text = dateFormatter.string(from: datePicker.date)
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
//source for creating a UITextField programmatically: https://stackoverflow.com/questions/2728354/add-uitextfield-on-uiview-programmatically
//source for UI Date Picker View implementation: https://www.youtube.com/watch?v=aa-lNWUVY7g
