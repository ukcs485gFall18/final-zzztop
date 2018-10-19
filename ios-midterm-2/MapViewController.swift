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
    
    // could be an array; users could select multiple pass types
    let usersPermit = PassType.noPermitRequired.rawValue // temporary
    
    enum PassType: String {
        case e2 = "E2"
        case r2 = "R2"
        case anyPermit = "Any valid permit"
        case noPermitRequired = "No permit required"
    }
    
    enum WeekDay: String {
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        case sunday = "Sunday"
    }
    
    enum Range: String {
        case mt = "MT"
        case mf = "MF"
        case ss = "SS"
        case f = "F"
        case ms = "MS"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
        setupViews()
        readJson()
        addPinsAndOverlays()
    }
    
    func addPinsAndOverlays() {
        for p in parkingData! {
            let coords = p["coords"] as! [Double]
            let dict = [coords[0], coords[1]]
            setPins(dict: dict)
            
            let date = Date()
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: date) - 1 // subtract 1 for correct day
            let f = DateFormatter()
            let weekdaystring = f.weekdaySymbols[weekday]
            
            guard let times = p["time"] as? [Any] else {
                return
            }
            
            for t in times {
                let newT = t as! NSDictionary
                let name = newT["name"] as! String
                if name == usersPermit {
                    
                    let mondaychecks = [Range.mt.rawValue, Range.mf.rawValue, Range.ms.rawValue]
                    let fridaychecks = [Range.mf.rawValue, Range.f.rawValue, Range.ms.rawValue]
                    let saturdaychecks = [Range.ss.rawValue, Range.ms.rawValue]
                    
                    if (weekdaystring == WeekDay.monday.rawValue) ||
                        (weekdaystring == WeekDay.tuesday.rawValue) ||
                        (weekdaystring == WeekDay.wednesday.rawValue) ||
                        (weekdaystring == WeekDay.thursday.rawValue) {
                        for c in mondaychecks {
                            if let range = newT[c] {
                                checkRange(open: range as! NSDictionary, coords: coords)
                                break
                            }
                        }
                    } else if weekdaystring == WeekDay.friday.rawValue {
                        for c in fridaychecks {
                            if let range = newT[c] {
                                checkRange(open: range as! NSDictionary, coords: coords)
                                break
                            }
                        }
                    } else {
                        for c in saturdaychecks {
                            if let range = newT[c] {
                                checkRange(open: range as! NSDictionary, coords: coords)
                                break
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    func checkRange(open: NSDictionary, coords: [Double]) {
        let now = Date() // temp; based on user's selected time
        
        let start = open["start"] as! NSDictionary
        let startHour = start["hour"] as! Int
        let startMinute = start["minute"] as! Int
        let startDate = now.dateAt(hours: startHour, minutes: startMinute)
        
        let end = open["end"] as! NSDictionary
        let endHour = end["hour"] as! Int
        let endMinute = end["minute"] as! Int
        
        var endDate = Date()
        if end["12hour"] as! String  == "am" { // for pm-am (overnight, usually free, parking)
            endDate = now.tomorrow(hour: endHour, minute: endMinute)
        } else { // for am-pm/pm-pm (same day)
            endDate = now.dateAt(hours: endHour, minutes: endMinute)
        }
        
//        print(now, "=now")
//        print(startDate, "=start")
//        print(endDate, "=end")
//
//        print(toGMT(date: now), "=now")
//        print(toGMT(date: startDate), "=start")
//        print(toGMT(date: endDate), "=end")
        
        if (now >= startDate) && (now < endDate) {
            setOverlays(dict: coords)
        }
    }
    
    // for checking that date is right
    func toGMT(date: Date) -> String {
        let dateStr = "\(date)"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss xxxxx"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        var str = String()
        if let date2 = formatter.date(from: dateStr) {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss xxxxx"
            str = formatter.string(from: date2)
        }
        return str
    }
    
    func readJson() {
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

extension Date {
    func dateAt(hours: Int, minutes: Int) -> Date {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        var date_components = calendar.components(
            [NSCalendar.Unit.year,
             NSCalendar.Unit.month,
             NSCalendar.Unit.day],
            from: self)
        
        date_components.hour = hours
        date_components.minute = minutes
        date_components.second = 0
        
        let newDate = calendar.date(from: date_components)!
        
        return newDate
    }
    
    func tomorrow(hour: Int, minute: Int) -> Date {
        let time = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self)!
        return Calendar.current.date(byAdding: .day, value: 1, to: time)!
    }
}

// source for creating mkcircle overlay: https://stackoverflow.com/questions/33293075/how-to-create-mkcircle-in-swift
// source for getting user's current location: https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
// source for updating current location: https://stackoverflow.com/questions/25449469/show-current-location-and-update-location-in-mkmapview-in-swift
// source for getting weekday: https://stackoverflow.com/questions/41068860/get-weekday-from-date-swift-3
// source for date range check: https://stackoverflow.com/questions/29652771/how-to-check-if-time-is-within-a-specific-range-in-swift/39499504#
// source for tomorrow date: https://stackoverflow.com/questions/44009804/swift-3-how-to-get-date-for-tomorrow-and-yesterday-take-care-special-case-ne
// https://stackoverflow.com/questions/32022906/how-can-i-convert-including-timezone-date-in-swift
