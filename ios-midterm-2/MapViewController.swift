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
    var spotsAndTimes: [String:[NSDictionary]] = [:]
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    let choosePassVC = ChoosePassViewController()
    var detailsVC = ParkingDetailsViewController()
    var pickedDate: Date?
    var didSelectDate: Bool = false
    var spots = [String]()
    var passedText = ""
    let now = Date()
    
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
        
        map.delegate = self
        configureLocationManager()
        
        setupViews()
        readJson()
        
        for p in parkingData! {
            let coords = p["coords"] as! [Double]
            let dict = [coords[0], coords[1]]
            setPins(dict: dict, title: p["name"] as! String)
        }
        
        createPickerView()
        
        pickedDate = now
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEEEEE LLL dd hh:mm aaa"
        pickerTextField.text = dateFormatter.string(from: pickedDate!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.array(forKey: "userPasses") != nil {
            usersPermits = UserDefaults.standard.array(forKey: "userPasses") as! [String]
        } else {
            usersPermits = [PassType.noPermitRequired.rawValue]
        }
        accessDataForOverlays(pickedDate: now)
    }
    
    @objc func choosePassTouched() {
        self.present(choosePassVC, animated: true, completion: nil)
    }
    
    @objc func resetDateTime(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEEEEE LLL dd hh:mm aaa"
        pickerTextField.text = dateFormatter.string(from: now)
        accessDataForOverlays(pickedDate: now)
    }
    
    func createPickerView() {
        view.addSubview(pickerTextField)
        
        // add the DatePicker to the UITextField
        pickerTextField.inputView = datePicker
        
        // allow the user to get out of the date picker by tapping
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MapViewController.tapToLeave(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    // allows the user to leave the UI picker by tapping elsewhere
    @objc func tapToLeave(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
        didSelectDate = true
    }
    
    // formats the date selected and places it into the UI Text Field
    @objc func dateSelected(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEEEEE LLL dd hh:mm aaa"
        pickerTextField.text = dateFormatter.string(from: datePicker.date)
        
        pickedDate = datePicker.date
        accessDataForOverlays(pickedDate: pickedDate!)
    }
    
    func accessDataForOverlays(pickedDate: Date) {
        map.removeOverlays(map.overlays) // remove previous overlays
        spots = []
        
        for p in parkingData! {
            let spotName = p["name"] as! String
            let radius = p["radius"] as! Int
            let coords = p["coords"] as! [Double]
            
            let date = pickedDate
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
                addToDictionary(spotName: spotName, timeDict: timeDict)
                
                if spots.contains(spotName) {
                    continue
                } else {
                    spots.append(spotName)
                    
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
        if let time = pickedDate {
            let start = open["start"] as! NSDictionary
            let startHour = start["hour"] as! Int
            let startMinute = start["minute"] as! Int
            let startDate = time.dateAt(hours: startHour, minutes: startMinute)
            
            let end = open["end"] as! NSDictionary
            let endHour = end["hour"] as! Int
            let endMinute = end["minute"] as! Int
            
            var endDate = Date()
            if end["12hour"] as! String  == "am" { // for pm-am/am-am (overnight parking)
                endDate = time.tomorrow(hour: endHour, minute: endMinute)
            } else { // for am-pm/pm-pm (same day)
                endDate = time.dateAt(hours: endHour, minutes: endMinute)
            }
            
            if (time >= startDate) && (time < endDate) {
                setOverlays(dict: coords, radius: radius)
            }
        }
    }
    
    func addToDictionary(spotName: String, timeDict: NSDictionary){
        print(spotName)
        var timeCategories: [NSDictionary] = []
        if let MT = timeDict["MT"]{
            timeCategories.append(MT as! NSDictionary)
            print(MT)
        }
        if let MF = timeDict["MF"]{
            timeCategories.append(MF as! NSDictionary)
            print(MF)
        }
        if let MS = timeDict["MS"]{
            timeCategories.append(MS as! NSDictionary)
            print(MS)
        }
        if let F = timeDict["F"]{
            timeCategories.append(F as! NSDictionary)
            print(F)
        }
        if let SS = timeDict["SS"]{
            timeCategories.append(SS as! NSDictionary)
            print(SS)
        }
        if(spotsAndTimes[spotName] == nil){
            spotsAndTimes[spotName] = timeCategories
        }else{
            var existingDictArray = spotsAndTimes[spotName]
            for time in timeCategories{
                existingDictArray?.append(time)
            }
        }
        
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
    
    func setPins(dict: [Double], title: String) {
        let latitude = dict[0]
        let longitude = dict[1]
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = title;
        self.map.addAnnotation(annotation)
    }
    
    func setOverlays(dict: [Double], radius: Int) {
        let latitude = dict[0]
        let longitude = dict[1]
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
    
    // used to show user's current location
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - views
    
    func setupViews() {
        view.addSubview(map)
        view.addSubview(detailsView)
        detailsView.isHidden = true
        view.addSubview(passButton)
        view.addSubview(resetButton)
        
        setupMap()
    }
    
    // create the UI text field
    lazy var pickerTextField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 50, y: 800, width: 300, height: 40))
        textField.textAlignment = NSTextAlignment.center
        textField.font = UIFont.systemFont(ofSize: 25)
        textField.backgroundColor = UIColor.blue
        textField.textColor = UIColor.white
        textField.borderStyle = UITextField.BorderStyle.none
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    // create the DatePicker
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(MapViewController.dateSelected(datePicker:)), for: .valueChanged)
        return datePicker
    }()
    
    lazy var detailsView: UIView = {
        let barheight = UIApplication.shared.statusBarFrame.size.height
        let headerHeight = self.navigationController?.navigationBar.frame.size.height
        
        let view = UIView(frame: CGRect(x: 0, y: self.view.frame.height-self.view.frame.height/3, width: self.view.frame.width, height: self.view.frame.height/2))
        view.backgroundColor = .white
        return view
    }()
    
    lazy var passButton: UIButton = {
        let barheight = UIApplication.shared.statusBarFrame.size.height
        let headerHeight = self.navigationController?.navigationBar.frame.size.height
        
        //button to display passes screen
        //        let button = UIButton(frame: CGRect(x: 285, y: 100, width: 120, height: 50))
        let button = UIButton(frame: CGRect(x: view.frame.width-110, y: barheight+headerHeight!+10, width: 100, height: 50))
        button.layer.cornerRadius = 5
        button.backgroundColor = .blue
        button.setTitle("Passes", for: .normal)
        button.addTarget(self, action: #selector(choosePassTouched), for: .touchUpInside)
        return button
    }()
    
    // button to reset
    lazy var resetButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 10, y: 100, width: 120, height: 50))
        button.layer.cornerRadius = 5
        button.backgroundColor = .blue
        button.setTitle("Current Time", for: .normal)
        button.addTarget(self, action: #selector(resetDateTime), for: .touchUpInside)
        return button
    }()
    
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
    
    func mapView(_ map:MKMapView, didSelect view:MKAnnotationView) {
        self.present(detailsVC,animated: true, completion: nil)
        if let pin = view.annotation as? MKPointAnnotation {
            if let pinTitle = pin.title{
                detailsVC.passedTitle = pinTitle
                if let hours = spotsAndTimes[pinTitle]{
                    detailsVC.onUserAction(title: pinTitle, hours: hours)
                }
            }
        }
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
// source for UI Text Field with rounded corners: https://stackoverflow.com/questions/13717007/uitextfield-rounded-corner-issue
//source for viewing annotation titles: https://stackoverflow.com/questions/37320485/swift-how-to-get-information-from-a-custom-annotation-on-clicked
