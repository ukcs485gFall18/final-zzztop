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

    // MARK: - properties

    var parkingData: [NSDictionary]?
    var gameday: [NSDictionary]?
    var gamedates: NSDictionary?
    var gameDates = [String]()
    var availableRangeForSpot = NSMutableDictionary()
    var parking: [NSDictionary]?
    var parkingNames = [String]()
    var usersPermits: [String] = []
    var spotsAndTimes: [String: [[String: String]: [NSDictionary]]] = [:]
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    let choosePassVC = ChoosePassViewController()
    var parkingTableVC = ParkingTableViewController()
    var detailsVC = ParkingDetailsViewController()
    let DurationViewVC = TimeAndDurationViewController()
    var pickedDate: Date?
    var spots = [String]()
    var passedText = ""
    let now = Date()
    var headerHeight = CGFloat()
    let calendar = Calendar.current

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // designs and positions views
        setUpViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pickedDate = now

        // get user's current location
        configureLocationManager()

        readJson()
        parking = parkingData

        pins()

        gameDayStuff()
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
        super.viewDidAppear(animated)

        if UserDefaults.standard.array(forKey: "userPasses") != nil {
            usersPermits = UserDefaults.standard.array(forKey: "userPasses") as! [String]
        } else {
            usersPermits = [PassType.noPermitRequired.rawValue]
        }

        // place the overlays in the correct places
        accessDataForOverlays(pickedDate: pickedDate!)
    }

    func pins() {
        for p in parking! {
            let coords = p["coords"] as! [Double]
            let dict = [coords[0], coords[1]]
            setPins(dict: dict, title: p["name"] as! String)
        }
    }

    func gameDayStuff() {
        let hour = calendar.component(.hour, from: now)
        let min = calendar.component(.minute, from: now)

        if checkGameDay(date: now) == gameDay.tomorrow.rawValue {
            let gameDayAlert = UIAlertController(title: "Game Day Tomorrow", message: "Remember to move your car for the football game tomorrow", preferredStyle: .alert)
            gameDayAlert.addAction(UIAlertAction(title: "Available Parking", style: .default, handler: { action in
                self.dateSelected(datePicked: self.now.tomorrow(hour: hour, minute: min))
            }))

            // help from: https://stackoverflow.com/questions/25511945/swift-alert-view-ios8-with-ok-and-cancel-button-which-button-tapped
            gameDayAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action: UIAlertAction!) in gameDayAlert.dismiss(animated: true, completion: nil)
            }))

            self.present(gameDayAlert, animated: true, completion: nil)
        } else if checkGameDay(date: now) == gameDay.today.rawValue {
            let gameDayAlert = UIAlertController(title: "Game Day Today", message: "Remember to move your car for the football game today", preferredStyle: .alert)
            gameDayAlert.addAction(UIAlertAction(title: "Available Parking", style: .default, handler: { action in
                self.dateSelected(datePicked:self.now)
            }))

            // help from: https://stackoverflow.com/questions/25511945/swift-alert-view-ios8-with-ok-and-cancel-button-which-button-tapped
            gameDayAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action: UIAlertAction!) in gameDayAlert.dismiss(animated: true, completion: nil)
            }))

            self.present(gameDayAlert, animated: true, completion: nil)
        }
    }

    @objc func openSettingsVC() {
        navigationController?.pushViewController(SettingsViewController(), animated: true)
    }

    //COMMENT THIS
    @objc func presentDurationView(){
        DurationViewVC.mapViewController = self
        self.present(DurationViewVC, animated:true, completion:nil)
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
        parkingTableVC.pickedDate = pickedDate!
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
    // Post: Updates the overlays on the map
    //-----------------------------------------------
    @objc func resetDateTime() {
        pickedDate = now
        checkGameDay(date: pickedDate!)
        DurationViewVC.pickedDate = pickedDate!
        DurationViewVC.datePicker.date = pickedDate!
        DurationViewVC.dateSelected(datePicker: DurationViewVC.datePicker)
        dateSelected(datePicked: pickedDate!)
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
        accessDataForOverlays(pickedDate: pickedDate!)
    }

    //-----------------------------------------------
    // dateSelected()
    //-----------------------------------------------
    // formats the date selected and places it into
    // the UI Text Field
    // Post: accesses the data to set the pins
    // to match the new date
    //-----------------------------------------------
    @objc func dateSelected(datePicked: Date) {
        pickedDate = datePicked

        if checkGameDay(date: pickedDate!) == gameDay.today.rawValue{
            gameDayLabel.text = "Game Day"
            gameDayLabel.isHidden = false
        } else if checkGameDay(date: pickedDate!) == gameDay.tomorrow.rawValue{
            gameDayLabel.text = "Game Day Tomorrow"
            gameDayLabel.isHidden = false
        } else{
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
        map.removeOverlays(map.overlays) // remove previous overlays
        parkingNames.removeAll()
        spotsAndTimes.removeAll()
        spots.removeAll()

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
            let weekdayString = f.weekdaySymbols[weekday]

            // unwrap all of the times
            guard let times = p["times"] as? [Any] else {
                return
            }

            // go through all of the times
            for time in times {
                // store the times as a NSDictionary
                let timeDict = time as! NSDictionary
                let passName = timeDict["pass"] as! String
                addToDictionary(pass: passName, spotName: spotName, timeDict: timeDict)

                // store all of the parking spots and their names
                if spots.contains(spotName) {
                    continue
                } else {
                    // go through all of the permits possible
                    for permit in usersPermits {
                        // if the permit name is a match, check the date ranges and format them
                        if passName == permit {
                            let mondayChecks = [Range.mt.rawValue, Range.mf.rawValue, Range.ms.rawValue]
                            let fridayChecks = [Range.mf.rawValue, Range.f.rawValue, Range.ms.rawValue]
                            let saturdayChecks = [Range.ss.rawValue, Range.ms.rawValue]

                            if (weekdayString == WeekDay.monday.rawValue) ||
                                (weekdayString == WeekDay.tuesday.rawValue) ||
                                (weekdayString == WeekDay.wednesday.rawValue) ||
                                (weekdayString == WeekDay.thursday.rawValue) {
                                rangeLoop(check: mondayChecks, timeDict: timeDict, coords: coords, radius: radius, name: spotName)
                            } else if weekdayString == WeekDay.friday.rawValue {
                                rangeLoop(check: fridayChecks, timeDict: timeDict, coords: coords, radius: radius, name: spotName)
                            } else {
                                rangeLoop(check: saturdayChecks, timeDict: timeDict, coords: coords, radius: radius, name: spotName)
                            }
                        }
                    }
                }
            }
            spots.append(spotName)
        }
    }

    //-----------------------------------------------
    // rangeLoop()
    //-----------------------------------------------
    // checks that the given date is within the
    // given date range by calling the function below
    //-----------------------------------------------
    func rangeLoop(check: [String], timeDict: NSDictionary, coords: [Double], radius: Int, name: String) {
        for c in check {
            if let range = timeDict[c] {
                checkDateRange(range: range as! [String: Any], coords: coords, radius: radius, name: name)
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
    func checkDateRange(range: [String: Any], coords: [Double], radius: Int, name: String) {
        if var time = pickedDate {
            let start = range["start"] as! NSDictionary
            let startHour = start["hour"] as! Int
            let startMinute = start["minute"] as! Int
            let startType = start["12hour"] as! String
            let startDate = time.dateAt(hours: startHour, minutes: startMinute)

            let end = range["end"] as! NSDictionary
            let endHour = end["hour"] as! Int
            let endMinute = end["minute"] as! Int
            let endType = end["12hour"] as! String

            var endDate = Date()
            if startType == "pm" && endType == "am" { // for pm-am (overnight parking)
                endDate = time.tomorrow(hour: endHour, minute: endMinute)
                if time > time.dateAt(hours: 0, minutes: 0) && time < time.dateAt(hours: endHour, minutes: endMinute) {
                    let hour = Calendar.current.component(.hour, from: time)
                    let minute = Calendar.current.component(.minute, from: time)
                    time = time.tomorrow(hour: hour, minute: minute)
                }
            } else { // same day parking
                endDate = time.dateAt(hours: endHour, minutes: endMinute)
            }

            if (time >= startDate) && (time < endDate) {
                if !parkingNames.contains(name) {
                    parkingNames.append(name)
                }
                setOverlays(dict: coords, radius: radius)
            }
        }
    }

    func checkGameDay(date: Date) -> String {
        var gDay = "None"
        let format = "MM/dd/yyyy"
        let formatter = DateFormatter()
        formatter.dateFormat = format

        let hour = calendar.component(.hour, from: date)
        let min = calendar.component(.minute, from: date)

        for g in gameDates {
            let gameDate = formatter.date(from: g)
            if calendar.isDate(date, inSameDayAs: gameDate!) {
                parking = gameday
                gDay = gameDay.today.rawValue
                break
            } else if calendar.isDate(date.tomorrow(hour: hour, minute: min), inSameDayAs: gameDate!) {
                parking = parkingData
                gDay = gameDay.tomorrow.rawValue
                break
            } else {
                parking = parkingData
                gDay = gameDay.none.rawValue
            }
        }
        return gDay
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
        var timeCategories: [[String: String]: [NSDictionary]] = [:]

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
            if let file = Bundle.main.url(forResource: "gameDay", withExtension: "json") {
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
            if let file = Bundle.main.url(forResource: "gameDates", withExtension: "json") {
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
    // setUpViews()
    //-----------------------------------------------
    // Add the map, navigationcontroller, and zoom
    // button to the view
    //-----------------------------------------------
    func setUpViews() {
        headerHeight = (self.navigationController?.navigationBar.frame.size.height)!

        navigationController?.navigationBar.addSubview(resetButton)
        navigationController?.navigationBar.addSubview(parkingTableButton)
        navigationController?.navigationBar.addSubview(zoomButton)
        navigationController?.navigationBar.addSubview(passButton)
        navigationController?.navigationBar.addSubview(settingsButton)

        view.addSubview(map)
        view.addSubview(gameDayLabel)
        view.addSubview(timeAndDurationButton)

        setUpMap()
    }

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
        let width = navButtonW / 2
        let x: CGFloat = (view.frame.width/5) + width
        let tableImage = UIImage(named: "listIcon.png")

        let button = UIButton(frame: CGRect(x: x, y: ynavPadding, width: width, height: navButtonH))
        button.layer.cornerRadius = 5
        button.setImage(tableImage, for: .normal)
        button.addTarget(self, action: #selector(listViewTouched), for: .touchUpInside)
        return button
    }()

    lazy var gameDayLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: buttonHeight+yPadding*5, width: view.frame.width-buttonWidth, height: buttonHeight))
        label.center.x = view.center.x
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = .white
        label.layer.cornerRadius = 5
        label.alpha = 0.8
        label.clipsToBounds = true
        label.isHidden = false
        if checkGameDay(date: pickedDate!) == "Today" {
            label.text = "Game Day"
        } else if checkGameDay(date: pickedDate!) == "Tomorrow" {
            label.text = "Game Day Tomorrow"
        } else {
            label.text = ""
            label.isHidden = true
        }
        return label
    }()

    // button to reset the time to the current time
    lazy var resetButton: UIButton = {
        let refreshIcon = UIImage(named: "refreshIcon")
        let button = UIButton(frame: CGRect(x: xPadding+7, y: 0, width: navButtonW/1.4, height: navButtonH*1.4))
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

    // creates the settings button
    lazy var settingsButton: UIButton = {
        let img = UIImage(named: "gear")
        let height_width: CGFloat = 30
        let x = view.frame.width-navButtonW

        let button = UIButton(frame: CGRect(x: x, y: ynavPadding, width: height_width, height: height_width))
        button.setImage(img, for: .normal)
        button.addTarget(self, action: #selector(openSettingsVC), for: .touchUpInside)
        return button
    }()

    lazy var timeAndDurationButton: UIButton = {
        // create a button for select time and date
        let button = UIButton(frame: CGRect(x: 0, y: view.frame.height-buttonHeight-yPadding, width: view.frame.width-buttonWidth, height: buttonHeight))
        button.center.x = view.center.x
        button.layer.cornerRadius = 5
        button.backgroundColor = .white
        button.alpha = 0.8
        button.setTitle("Change Time and Duration", for: .normal)
        // Source for title color:
        // https://stackoverflow.com/questions/31088172/how-to-set-the-title-text-color-of-uibutton/41853921
        button.setTitleColor(UIColor.black, for: [])
        button.addTarget(self, action: #selector(presentDurationView), for: .touchUpInside)
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
    func setUpMap() {
        map.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        map.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }

}

// overrides map view functions
extension MapViewController: MKMapViewDelegate {

    // sets the circle overlays
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circelOverLay = overlay as? MKCircle else { return MKOverlayRenderer() }

        let circleRenderer = MKCircleRenderer(circle: circelOverLay)
        circleRenderer.strokeColor = red
        circleRenderer.fillColor = red
        circleRenderer.alpha = 0.5
        return circleRenderer
    }

    // sets the annotations to views so they are clickable w/ actions
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "marker"
        var view: MKMarkerAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.markerTintColor = lightblue
        }
        return view
    }

    //-----------------------------------------------
    // mapView()
    //-----------------------------------------------
    // When an annotation is selected, the parking
    // details view controller is presented the
    // dictionary of stored data is passed to it
    //-----------------------------------------------
    func mapView(_ map: MKMapView, didSelect view: MKAnnotationView) {
        // bring up the new view
        detailsVC.pickedDate = pickedDate
        if let pin = view.annotation as? MKPointAnnotation {
            if let pinTitle = pin.title {
                if let hours = spotsAndTimes[pinTitle] {
                    detailsVC.times = hours
                    detailsVC.parkingName = pinTitle
                    // pass the data to the next view
                    //detailsVC.onUserAction(title: pinTitle, hours: hours)
                    self.present(detailsVC, animated: true, completion: nil)
                }
                else {
                    let noAvailableParkingAlert = UIAlertController(title: "No Available Parking", message: "You cannot park at this location", preferredStyle: .alert)

                    //help from: https://stackoverflow.com/questions/25511945/swift-alert-view-ios8-with-ok-and-cancel-button-which-button-tapped
                    noAvailableParkingAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action: UIAlertAction!) in noAvailableParkingAlert.dismiss(animated: true, completion: nil)
                    }))

                    self.present(noAvailableParkingAlert, animated: true, completion: nil)
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

// Sources for this file:
// source for creating a UITextField programmatically: https://stackoverflow.com/questions/2728354/add-uitextfield-on-uiview-programmatically
// source for UI Date Picker View implementation: https://www.youtube.com/watch?v=aa-lNWUVY7g
// source for UI Text Field with rounded corners: https://stackoverflow.com/questions/13717007/uitextfield-rounded-corner-issue
// source for viewing annotation titles: https://stackoverflow.com/questions/37320485/swift-how-to-get-information-from-a-custom-annotation-on-clicked
// source for making annotations clickable: https://www.hackingwithswift.com/example-code/location/how-to-add-annotations-to-mkmapview-using-mkpointannotation-and-mkpinannotationview
// source for date range check: https://stackoverflow.com/questions/29652771/how-to-check-if-time-is-within-a-specific-range-in-swift/39499504#
// source for tomorrow date: https://stackoverflow.com/questions/44009804/swift-3-how-to-get-date-for-tomorrow-and-yesterday-take-care-special-case-ne
//source for linking view controllers: https://teamtreehouse.com/community/passing-data-from-modal-view-controller-to-parent
