//
//  MapViewController.swift
//  ios-midterm-2
//
//  Created by Jordan George on 10/13/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var parkingData: [NSDictionary]?
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    
    enum PassTypes: String {
        case e2 = "E2"
        case r2 = "R2"
        case anyPermit = "Any valid permit"
        case noPermitRequired = "No permit required"
    }
    enum WeekDays: String {
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        case sunday = "Sunday"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
        setupViews()
        readJson()
        
        for p in parkingData! {
            let parkingName = p["name"]
            
            let coords = p["coords"] as! [Double]
            let dict = [coords[0], coords[1]]
            setPins(dict: dict)
            
//            setOverlays(dict: dict)
            
//            var alltimes = [Any]()
            
            
            
            var arrayOfvalidpermittimes = [Any]()
            let usersPermit = PassTypes.noPermitRequired.rawValue
            let date = Date()
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: date) - 1
            let f = DateFormatter()
            let weekdaystring = f.weekdaySymbols[weekday].lowercased()
            if weekdaystring == WeekDays.wednesday.rawValue.lowercased() {
                guard let times = p["time"] as? [Any] else {
                    return
                }
                for t in times {
                    let newT = t as! NSDictionary
//                    alltimes.append(t)
                    let name = newT["name"] as! String
                    if name == usersPermit {
                        let open = newT[weekdaystring]
//                        if open is in range {
//                            setOverlays(dict: coords)
//                            break;
//                        }
                        
                        
                        
                        
                        
                        
                        
//                        var dict = [
//                            "name":parkingName,
//                            "coords":coords,
//                            "validtimes": t
//                        ]
//                        print(dict)
//                        arrayOfvalidpermittimes.append(t)
                    }
                }
            }
//            print(arrayOfvalidpermittimes)
//            print(alltimes)
        }
    }
    
    private func readJson() {
        do {
            if let file = Bundle.main.url(forResource: "parkingData", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                parkingData = jsonResult["parking"] as? [NSDictionary]
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func configureLocationManager() {
        // used to show user's current location
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func setPins(dict: [Double]) {
        let latitude = dict[0]
        let longitude = dict[1]
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        map.addAnnotation(annotation)
    }
    
    func setOverlays(dict: [Double]) {
        let latitude = dict[0]
        let longitude = dict[1]
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // FIXME: each location should have it's own radius? or we can have square overlays. to compensate for different lot/location sizes.
        let radius = CLLocationDistance(70)
        let circle = MKCircle(center: center, radius: radius)
        map.addOverlay(circle)
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

// source for getting weekday: https://stackoverflow.com/questions/41068860/get-weekday-from-date-swift-3
