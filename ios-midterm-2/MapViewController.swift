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
    var usersPermits: [String] = []
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    let choosePassVC = ChoosePassViewController()
    var detailsView = UIView();
    
    var pickedDate: Date?
    var pickerUIText = UITextField()
    var datePicker: UIDatePicker?

    enum PassType: String {
        case e = "E"
        case e2 = "E2"
        case e20 = "E20"
        case e26 = "E26"
        case e28 = "E28"
        case e27 = "E27"
        case r2 = "R2"
        case r7 = "R7"
        case r17 = "R17"
        case r19 = "R19"
        case r29 = "R29"
        case r30 = "R30"
        case c5 = "C5"
        case c9 = "C9"
        case c16 = "C16"
        case k = "K"
        case ek = "EK"
        case ck = "CK"
        case x = "X"
        case a = "Authorized parking only"
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
        
        for p in parkingData! {
            let coords = p["coords"] as! [Double]
            let dict = [coords[0], coords[1]]
            setPins(dict: dict, title: p["name"] as! String)
        }
        
        createPickerView()
        pickedDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEEEEE MM/dd/yyyy hh:mm aaa"
        pickerUIText.text = dateFormatter.string(from: pickedDate!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.array(forKey: "userPasses") != nil {
            usersPermits = UserDefaults.standard.array(forKey: "userPasses") as! [String]
        }
        else{
            usersPermits = [PassType.noPermitRequired.rawValue]
        }
        print(usersPermits)
//        print(pickerUIText.text!)
        //        if usersPermits.isEmpty {
        //            map.removeOverlays(map.overlays) // remove previous overlays
        //        } else {
        accessDataForOverlays()
        //        }
    }
    
    func accessDataForOverlays() {
        map.removeOverlays(map.overlays) // remove previous overlays
        
        for p in parkingData! {
            let coords = p["coords"] as! [Double]
            
            let radius = p["radius"] as! Int
            
            let date = Date()
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: date) - 1 // subtract 1 for correct day
            let f = DateFormatter()
            let weekdaystring = f.weekdaySymbols[weekday]
            
            guard let times = p["times"] as? [Any] else {
                return
            }
            
            for time in times {
                let timeDict = time as! NSDictionary
                let name = timeDict["pass"] as! String
                for permit in usersPermits {
                    if name == permit {
                        let mondayChecks = [Range.mt.rawValue, Range.mf.rawValue, Range.ms.rawValue]
                        let fridayChecks = [Range.mf.rawValue, Range.f.rawValue, Range.ms.rawValue]
                        let saturdayChecks = [Range.ss.rawValue, Range.ms.rawValue]
                        
                        if (weekdaystring == WeekDay.monday.rawValue) ||
                            (weekdaystring == WeekDay.tuesday.rawValue) ||
                            (weekdaystring == WeekDay.wednesday.rawValue) ||
                            (weekdaystring == WeekDay.thursday.rawValue) {
                            rangeLoop(check: mondayChecks, timeDict: timeDict, coords: coords, radius: radius)
                        } else if weekdaystring == WeekDay.friday.rawValue {
                            rangeLoop(check: fridayChecks, timeDict: timeDict, coords: coords, radius: radius)
                        } else {
                            rangeLoop(check: saturdayChecks, timeDict: timeDict, coords: coords, radius: radius)
                        }
                    }
                }
            }
        }
    }
    
    func rangeLoop(check: [String], timeDict: NSDictionary, coords: [Double], radius: Int) {
        for c in check {
            if let range = timeDict[c] {
                checkDateRange(open: range as! NSDictionary, coords: coords, radius: radius)
                break
            }
        }
    }
    
    func checkDateRange(open: NSDictionary, coords: [Double], radius: Int) {
//        change now var name
        if let now = pickedDate {
//            print(toGMT(date: now))
            
            let start = open["start"] as! NSDictionary
            let startHour = start["hour"] as! Int
            let startMinute = start["minute"] as! Int
            let startDate = now.dateAt(hours: startHour, minutes: startMinute)
            
            let end = open["end"] as! NSDictionary
            let endHour = end["hour"] as! Int
            let endMinute = end["minute"] as! Int
            
            var endDate = Date()
            if end["12hour"] as! String  == "am" { // for pm-am/am-am (overnight parking)
                endDate = now.tomorrow(hour: endHour, minute: endMinute)
            } else { // for am-pm/pm-pm (same day)
                endDate = now.dateAt(hours: endHour, minutes: endMinute)
            }
            
            if (now >= startDate) && (now < endDate) {
                setOverlays(dict: coords, radius: radius)
            }
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
                print("no json file")
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
    
    func setPins(dict: [Double], title: String) {
        let latitude = dict[0]
        let longitude = dict[1]
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = title;
        map.addAnnotation(annotation)
    }
    
    func createPickerView(){
        // create the UI text
        pickerUIText = UITextField(frame: CGRect(x: 50, y: 800, width: 300, height: 40))
        pickerUIText.text = "Please Select a Date"
        pickerUIText.textAlignment = NSTextAlignment.center
        pickerUIText.font = UIFont.systemFont(ofSize: 25)
        self.view.addSubview(pickerUIText)
        // create the DatePicker
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .dateAndTime
        datePicker?.addTarget(self, action: #selector(MapViewController.dateSelected(datePicker:)), for: .valueChanged)
        // add the DatePicker to the UITextField
        pickerUIText.inputView = datePicker
        // allow the user to get out of the date picker by tapping
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MapViewController.tapToLeave(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    // allows the user to leave the UI picker by tapping elsewhere
    @objc func tapToLeave(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    // formats the date selected and places it into the UI Text Field
    @objc func dateSelected(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEEEEE MM/dd/yyyy hh:mm aaa"
        pickerUIText.text = dateFormatter.string(from: datePicker.date)
        
        pickedDate = datePicker.date
//        map.removeOverlays(map.overlays) // remove previous overlays
        accessDataForOverlays()
    }
    
    func setOverlays(dict: [Double], radius: Int) {
        let latitude = dict[0]
        let longitude = dict[1]
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // FIXME: each location should have it's own radius? or we can have square overlays. to compensate for different lot/location sizes.
        let radius = CLLocationDistance(radius)
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

        detailsView = UIView(frame: CGRect(x:0, y:view.frame.height-view.frame.height/3 , width:view.frame.width, height:view.frame.height/2))
        detailsView.backgroundColor = .white
        view.addSubview(detailsView)
        detailsView.isHidden = true

        let button = UIButton(frame: CGRect(x: 300, y: 100, width: 100, height: 50))
        button.layer.cornerRadius = 5
        button.backgroundColor = .blue
        button.setTitle("Passes", for: .normal)
        button.addTarget(self, action: #selector(choosePassTouched), for: .touchUpInside)
        view.addSubview(button)
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
    
    @objc func choosePassTouched() {
        self.present(choosePassVC, animated: true, completion: nil)
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
    
    func map(_ map: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = map.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ map: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        detailsView.isHidden = false
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
        let time = Calendar.current.date(bySettingHour: hour, minute: minute, second: 59, of: self)!
        return Calendar.current.date(byAdding: .day, value: 1, to: time)!
    }
}


// source for creating a UITextField programmatically: https://stackoverflow.com/questions/2728354/add-uitextfield-on-uiview-programmatically
// source for UI Date Picker View implementation: https://www.youtube.com/watch?v=aa-lNWUVY7g
