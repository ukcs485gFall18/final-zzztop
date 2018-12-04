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
    
    // declaration of public variables
    var parkingData: [NSDictionary]?
    var gameday: [NSDictionary]?
    var gamedates: NSDictionary?
    var gameDates = [String]()
    var parking: [NSDictionary]?
    var parkingNames = [String]()
    var usersPermits: [String] = []
    var spotsAndTimes: [String:[[String:String]:[NSDictionary]]] = [:]
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    let choosePassVC = ChoosePassViewController()
    var parkingTableVC = ParkingTableViewController()
    var detailsVC = ParkingDetailsViewController()
    var pickedDate: Date?
    var didSelectDate: Bool = false
    var spots = [String]()
    var passedText = ""
    let now = Date()
    var headerHeight = CGFloat()
    let calendar = Calendar.current

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting up the view
        headerHeight = (self.navigationController?.navigationBar.frame.size.height)!
        
        map.delegate = self
        configureLocationManager()
        
        setupViews()
        // format the PickerView
        createPickerView()
        pickedDate = now
        readJson()
        checkGameDay()
        
        for p in parking! {
            let coords = p["coords"] as! [Double]
            let dict = [coords[0], coords[1]]
            setPins(dict: dict, title: p["name"] as! String)
        }
        view.addSubview(gameDayLabel)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEEEEE LLL dd h:mm aaa"
        pickerTextField.text = dateFormatter.string(from: pickedDate!)
    }
    
    //-----------------------------------------------
    // viewDidAppear()
    //-----------------------------------------------
    // Upon the view appearing, retrieve passes
    // selected from UserDefaults and accesses the
    // data to set pins on the map
    // Conditions: none
    //-----------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.array(forKey: "userPasses") != nil {
            usersPermits = UserDefaults.standard.array(forKey: "userPasses") as! [String]
        } else {
            usersPermits = [PassType.noPermitRequired.rawValue]
        }
        // place the pins in the correct places
        accessDataForOverlays(pickedDate: now)
    }
    
    @objc func openAdminVC() {
        present(AdminViewController(), animated: true, completion: nil)
    }
    
    //-----------------------------------------------
    // choosePassTouched()
    //-----------------------------------------------
    // When the pass button is selected pull up the
    // ChoosePassViewController
    // Conditions: none
    //-----------------------------------------------
    @objc func choosePassTouched() {
        self.present(choosePassVC, animated: true, completion: nil)
    }
    
    @objc func listViewTouched() {
        parkingTableVC.parkingNames = parkingNames
        parkingTableVC.spotsAndTimes = spotsAndTimes
        self.present(parkingTableVC, animated: true, completion: nil)
    }
    
    //-----------------------------------------------
    // zoomToCurrentLocation()
    //-----------------------------------------------
    // zoom to user location on map
    // Post: Updates the location in the background
    // thread to not slow down app usage
    //-----------------------------------------------
    @objc func zoomToCurrentLocation() {
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            map.setRegion(viewRegion, animated: false)
        }
        
        // send updating to a background thread
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    //-----------------------------------------------
    // resetDateTime()
    //-----------------------------------------------
    // A function to put the current date in the
    // UI Date picker upon selecting the reset button
    // Post: Updates the pins on the map
    //-----------------------------------------------
    @objc func resetDateTime(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEEEEE LLL dd h:mm aaa"
        pickerTextField.text = dateFormatter.string(from: now)
        
        // update map after reset
        accessDataForOverlays(pickedDate: now)
    }
    
    //-----------------------------------------------
    // createPickerView()
    //-----------------------------------------------
    // A function to create the UIPickerView and
    // place it on the view
    // Conditions: none
    //-----------------------------------------------
    func createPickerView() {
        view.addSubview(pickerTextField)
        
        // add the DatePicker to the UITextField
        pickerTextField.inputView = datePicker
        
        // allow the user to get out of the date picker by tapping
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MapViewController.tapToLeave(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    //-----------------------------------------------
    // tapToLeave()
    //-----------------------------------------------
    // allows the user to leave the UI picker by
    // tapping elsewhere
    // Conditions: none
    //-----------------------------------------------
    @objc func tapToLeave(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
        didSelectDate = true
    }
    
    //-----------------------------------------------
    // dateSelected()
    //-----------------------------------------------
    // formats the date selected and places it into
    // the UI Text Field
    // Post: accesses the data to set the pins
    // to match the new date
    //-----------------------------------------------
    @objc func dateSelected(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEEEEE LLL dd h:mm aaa"
        pickerTextField.text = dateFormatter.string(from: datePicker.date)
        
        pickedDate = datePicker.date
        if checkGameDay() == "Today"{
            gameDayLabel.text = "Game Day"
            gameDayLabel.isHidden = false
        }
        else if checkGameDay() == "Tomorrow"{
            gameDayLabel.text = "Game Day Tomorrow"
            gameDayLabel.isHidden = false
        }
        else{
            gameDayLabel.text = ""
            gameDayLabel.isHidden = true
        }
        accessDataForOverlays(pickedDate: pickedDate!)
    }
    
    //-----------------------------------------------
    // accessDataForOverlays()
    //-----------------------------------------------
    // accesses and formats the data from the JSON
    // file such that they can be compared to the
    // current time
    //-----------------------------------------------
    func accessDataForOverlays(pickedDate: Date) {
        parkingNames.removeAll()
        map.removeOverlays(map.overlays) // remove previous overlays
        spots = []
        // go through each collection in the JSON file
        for p in parking! {
            // get the spot name, circle radius, and coordinates
            let spotName = p["name"] as! String
            let radius = p["radius"] as! Int
            let coords = p["coords"] as! [Double]
            
            // get the current user settings for dates
            let date = pickedDate
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: date) - 1 // subtract 1 for correct day
            let f = DateFormatter()
            let weekdaystring = f.weekdaySymbols[weekday]
            
            // unwrap all of the times
            guard let times = p["times"] as? [Any] else {
                return
            }
            
            // go through all of the times
            for time in times {
                // store the times as a NSDictionary
                let timeDict = time as! NSDictionary
                let name = timeDict["pass"] as! String
                addToDictionary(pass: name, spotName: spotName, timeDict: timeDict)
                
                // store all of the parking spots and their names
                if spots.contains(spotName) {
                    continue
                } else {
                    spots.append(spotName)
                    
                    // go through all of the permits possible
                    for permit in usersPermits {
                        // if the permit name is a match, check the date ranges and format them
                        if name == permit {
                            let mondayChecks = [Range.mt.rawValue, Range.mf.rawValue, Range.ms.rawValue]
                            let fridayChecks = [Range.mf.rawValue, Range.f.rawValue, Range.ms.rawValue]
                            let saturdayChecks = [Range.ss.rawValue, Range.ms.rawValue]
                            
                            if (weekdaystring == WeekDay.monday.rawValue) ||
                                (weekdaystring == WeekDay.tuesday.rawValue) ||
                                (weekdaystring == WeekDay.wednesday.rawValue) ||
                                (weekdaystring == WeekDay.thursday.rawValue) {
                                rangeLoop(check: mondayChecks, timeDict: timeDict, coords: coords, radius: radius, name: spotName)
                            } else if weekdaystring == WeekDay.friday.rawValue {
                                rangeLoop(check: fridayChecks, timeDict: timeDict, coords: coords, radius: radius, name: spotName)
                            } else {
                                rangeLoop(check: saturdayChecks, timeDict: timeDict, coords: coords, radius: radius, name: spotName)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //-----------------------------------------------
    // rangeLoop()
    //-----------------------------------------------
    // checks that the given date is within the
    // given date range by calling the function below
    //-----------------------------------------------
    func rangeLoop(check: [String], timeDict: NSDictionary, coords: [Double], radius: Int, name:String) {
        for c in check {
            if let range = timeDict[c] {
                checkDateRange(open: range as! NSDictionary, coords: coords, radius: radius, name: name)
                break
            }
        }
    }
    
    //-----------------------------------------------
    // checkDateRange()
    //-----------------------------------------------
    // checks that the given date is within the
    // given date range
    // Pre: Requires the NSDictionary of dates,
    // the cordinates, and the desired circle radius
    //-----------------------------------------------
    func checkDateRange(open: NSDictionary, coords: [Double], radius: Int, name: String) {
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
                if !parkingNames.contains(name){
                    parkingNames.append(name)
                }
                setOverlays(dict: coords, radius: radius)
            }
        }
    }
    
    func checkGameDay() -> String {
        var gameDay = "None"
        let format = "MM/dd/yyyy"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let hour = calendar.component(.hour, from: pickedDate!)
        let min = calendar.component(.minute, from: pickedDate!)
        for g in gameDates{
            let gameDate = formatter.date(from: g)
            if calendar.isDate(pickedDate!, inSameDayAs: gameDate!){
                parking = gameday
                gameDay = "Today"
                break
            }
            else if calendar.isDate(pickedDate!.tomorrow(hour: hour, minute: min), inSameDayAs: gameDate!) {
                parking = parkingData
                gameDay = "Tomorrow"
                break
            }
            else{
                parking = parkingData
                gameDay = "None"
            }
        }
        return gameDay
    }
    
    //-----------------------------------------------
    // addToDictionary()
    //-----------------------------------------------
    // Adds data to a dictionary such that it can be
    // passed to the ParkingDetailsViewController
    // Pre: requires the pass name, spot name, and
    // the time range as a NSDictionary
    //-----------------------------------------------
    func addToDictionary(pass: String, spotName: String, timeDict: NSDictionary) {
        var timeCategories: [[String:String]: [NSDictionary]] = [:]
        
        // go through each day range and add to dictionary if not previously appended
        if let MT = timeDict["MT"] {
            if (timeCategories[[pass:"MT"]] == nil) {
                timeCategories[[pass:"MT"]] = [MT as! NSDictionary]
            } else {
                var existingMTDict = timeCategories[[pass:"MT"]]
                existingMTDict?.append(MT as! NSDictionary)
            }
        }
        if let MF = timeDict["MF"] {
            if (timeCategories[[pass:"MF"]] == nil) {
                timeCategories[[pass:"MF"]] = [MF as! NSDictionary]
            } else {
                var existingMFDict = timeCategories[[pass:"MF"]]
                existingMFDict?.append(MF as! NSDictionary)
            }
        }
        if let MS = timeDict["MS"] {
            if (timeCategories[[pass:"MS"]] == nil) {
                timeCategories[[pass:"MS"]] = [MS as! NSDictionary]
            } else {
                var existingMSDict = timeCategories[[pass:"MS"]]
                existingMSDict?.append(MS as! NSDictionary)
            }
        }
        if let F = timeDict["F"] {
            if (timeCategories[[pass:"F"]] == nil) {
                timeCategories[[pass:"F"]] = [F as! NSDictionary]
            } else {
                var existingFDict = timeCategories[[pass:"F"]]
                existingFDict?.append(F as! NSDictionary)
            }
        }
        if let SS = timeDict["SS"] {
            if (timeCategories[[pass:"SS"]] == nil) {
                timeCategories[[pass:"SS"]] = [SS as! NSDictionary]
            } else {
                var existingSSDict = timeCategories[[pass:"SS"]]
                existingSSDict?.append(SS as! NSDictionary)
            }
        }
        
        // add all of the timeCategories to the appropriate spot in the dictionary
        if (spotsAndTimes[spotName] == nil) {
            spotsAndTimes[spotName] = timeCategories
        } else { // if the spot already exists, append the time discovered to the existing entry
            for (key,value) in timeCategories {
                spotsAndTimes[spotName]?[key] = value;
            }
        }
    }
    
    //-----------------------------------------------
    // readJson()
    //-----------------------------------------------
    // read the raw JSON file and serialize it into
    // a NSDictionary
    //-----------------------------------------------
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
        
        do {
            if let file = Bundle.main.url(forResource: "gameday", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                gameday = jsonResult["parking"] as? [NSDictionary]
            } else {
                print("no json file")
            }
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            if let file = Bundle.main.url(forResource: "gamedates", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                gamedates = jsonResult as NSDictionary
                let year = String(calendar.component(.year, from: pickedDate!))
                gameDates = gamedates?[year] as! [String]
            } else {
                print("no json file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //-----------------------------------------------
    // toGMT()
    //-----------------------------------------------
    // for checking that date is formatted correctly
    // Post: returns the correctly formatted string
    //-----------------------------------------------
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
    
    //-----------------------------------------------
    // setPins()
    //-----------------------------------------------
    // Sets the pins on the map
    // Pre: an array of coordinates and the title of
    // the pin spot
    //-----------------------------------------------
    func setPins(dict: [Double], title: String) {
        let latitude = dict[0]
        let longitude = dict[1]
        
        // creating a blank pin
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = title;
        
        // adding pin to the map
        self.map.addAnnotation(annotation)
    }
    
    //-----------------------------------------------
    // setOverlays()
    //-----------------------------------------------
    // Sets the circles on the map
    // Pre: an array of coordinates and the desired
    // radius of the circle
    //-----------------------------------------------
    func setOverlays(dict: [Double], radius: Int) {
        // get the long and latitude that the circle centers on
        let latitude = dict[0]
        let longitude = dict[1]
        
        // creating a circle annotation around the pin set earlier
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let radius = CLLocationDistance(radius)
        let circle = MKCircle(center: center, radius: radius)
        map.addOverlay(circle)
    }
    
    //-----------------------------------------------
    // configureLocationManager()
    //-----------------------------------------------
    // used to show user's current location and
    // correctly format the location manager
    //-----------------------------------------------
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - views
    
    //-----------------------------------------------
    // setupViews()
    //-----------------------------------------------
    // Add the map, navigationcotnroller, and zoom
    // button to the view
    //-----------------------------------------------
    func setupViews() {
        navigationController?.navigationBar.addSubview(resetButton)
        navigationController?.navigationBar.addSubview(zoomButton)
        navigationController?.navigationBar.addSubview(passButton)
        navigationController?.navigationBar.addSubview(adminButton)
        
        view.addSubview(map)
        self.navigationController?.navigationBar.addSubview(passButton)
        self.navigationController?.navigationBar.addSubview(parkingTableButton)
        self.navigationController?.navigationBar.addSubview(resetButton)

        setupMap()
    }
    
    // create the UI text field
    lazy var pickerTextField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: view.frame.height-buttonHeight-yPadding, width: view.frame.width-buttonWidth, height: buttonHeight))
        textField.center.x = view.center.x
        textField.textAlignment = NSTextAlignment.center
        textField.font = UIFont.systemFont(ofSize: regFontSize)
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.borderStyle = UITextField.BorderStyle.none
        textField.layer.cornerRadius = 5
        textField.alpha = 0.8
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
        let view = UIView(frame: CGRect(x: 0, y: self.view.frame.height-self.view.frame.height/3, width: self.view.frame.width, height: self.view.frame.height/2))
        view.backgroundColor = .white
        return view
    }()
    
    // button to display passes screen
    lazy var passButton: UIButton = {
        let passesImage = UIImage(named: "permitIcon")
        let x: CGFloat = (view.frame.width/5)*3.5 - xPadding*2
        
        let button = UIButton(frame: CGRect(x: x, y: ynavPadding, width: navButtonW, height: navButtonH))
        button.setImage(passesImage, for: .normal)
        button.addTarget(self, action: #selector(choosePassTouched), for: .touchUpInside)
        return button
    }()
    
    // button to display passes screen
    lazy var parkingTableButton: UIButton = {
        let tableImage = UIImage(named: "listIcon.png")
        let button = UIButton(frame: CGRect(x: view.frame.width-navButtonW-xPadding-navButtonW, y: ynavPadding, width: navButtonW/2, height: navButtonH))
        button.layer.cornerRadius = 5
        button.setImage(tableImage, for: .normal)
        button.addTarget(self, action: #selector(listViewTouched), for: .touchUpInside)
        return button
    }()
    
    lazy var gameDayLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: buttonHeight+yPadding*2, width: view.frame.width-buttonWidth, height: buttonHeight))
        label.center.x = view.center.x
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = .white
        label.layer.cornerRadius = 5
        label.alpha = 0.8
        label.clipsToBounds = true
        label.isHidden = false
        if checkGameDay() == "Today"{
            label.text = "Game Day"
        }
        else if checkGameDay() == "Tomorrow"{
            label.text = "Game Day Tomorrow"
        }
        else{
            label.text = ""
            label.isHidden = true
        }
        return label
    }()
    
    // button to reset the time to the current time
    lazy var resetButton: UIButton = {
        let refreshIcon = UIImage(named: "refreshIcon")
        let button = UIButton(frame: CGRect(x: xPadding, y: ynavPadding, width: navButtonW, height: navButtonH))
        button.setImage(refreshIcon, for: .normal)
        button.addTarget(self, action: #selector(resetDateTime), for: .touchUpInside)
        return button
    }()
    
    // creates the zoom button
    // returns to the user's current location
    lazy var zoomButton: UIButton = {
        let img = UIImage(named: "zoom")
        let height_width: CGFloat = 30
        let x: CGFloat = (view.frame.width/5) * 2.50 - xPadding
        
        let button = UIButton(frame: CGRect(x: x, y: ynavPadding, width: height_width, height: height_width))
        button.setImage(img, for: .normal)
        button.addTarget(self, action: #selector(zoomToCurrentLocation), for: .touchUpInside)
        return button
    }()
    
    // creates the zoom button
    lazy var adminButton: UIButton = {
        let img = UIImage(named: "gear")
        let height_width: CGFloat = 30
        
        let button = UIButton(frame: CGRect(x: view.frame.width-navButtonW-xPadding, y: ynavPadding, width: height_width, height: height_width))
        button.setImage(img, for: .normal)
        button.addTarget(self, action: #selector(openAdminVC), for: .touchUpInside)
        return button
    }()
    
    // creates the map
    lazy var map: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.delegate = self
        return map
    }()
    
    // positions the map to fill most of the view
    func setupMap() {
        map.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        map.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
}

// overrides map view functions
extension MapViewController: MKMapViewDelegate {
    
    // sets the circle overlays
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circelOverLay = overlay as? MKCircle else {return MKOverlayRenderer()}
        
        let circleRenderer = MKCircleRenderer(circle: circelOverLay)
        circleRenderer.strokeColor = .blue
        circleRenderer.fillColor = .blue
        circleRenderer.alpha = 0.2
        return circleRenderer
    }
    
    // sets the annotations to views so they are clickable w/ actions
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
    
    //-----------------------------------------------
    // mapView()
    //-----------------------------------------------
    // When an annotation is selected, the parking
    // details view controller is presented the
    // dictionary of stored data is passed to it
    //-----------------------------------------------
    func mapView(_ map:MKMapView, didSelect view:MKAnnotationView) {
        //bring up the new view
        self.present(detailsVC,animated: true, completion: nil)
        if let pin = view.annotation as? MKPointAnnotation {
            if let pinTitle = pin.title{
                if let hours = spotsAndTimes[pinTitle]{
                    //pass the data to the next view
                    detailsVC.onUserAction(title: pinTitle, hours: hours)
                }
            }
        }
    }
    
}

// gets user's current location
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

// for date range checking
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
    
    // get date for tomorrow
    func tomorrow(hour: Int, minute: Int) -> Date {
        let time = Calendar.current.date(bySettingHour: hour, minute: minute, second: 59, of: self)! // misses 1 second
        return Calendar.current.date(byAdding: .day, value: 1, to: time)!
    }
    
}

// Sources for this file:
// source for creating a UITextField programmatically: https://stackoverflow.com/questions/2728354/add-uitextfield-on-uiview-programmatically
// source for UI Date Picker View implementation: https://www.youtube.com/watch?v=aa-lNWUVY7g
// source for UI Text Field with rounded corners: https://stackoverflow.com/questions/13717007/uitextfield-rounded-corner-issue
// source for viewing annotation titles: https://stackoverflow.com/questions/37320485/swift-how-to-get-information-from-a-custom-annotation-on-clicked
// source for making annotations clickable: https://www.hackingwithswift.com/example-code/location/how-to-add-annotations-to-mkmapview-using-mkpointannotation-and-mkpinannotationview
// source for date range check: https://stackoverflow.com/questions/29652771/how-to-check-if-time-is-within-a-specific-range-in-swift/39499504#
// source for tomorrow date: https://stackoverflow.com/questions/44009804/swift-3-how-to-get-date-for-tomorrow-and-yesterday-take-care-special-case-ne
