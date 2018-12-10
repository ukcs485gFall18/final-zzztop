//
//  MapViewController.swift
//  ios-midterm-2
//
//  Created by Jordan George on 10/13/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import MapKit
//import Firebase

class MapViewController: UIViewController {
    
    // MARK: - properties
    
    var parkingData: [NSDictionary]?
    var gameday: [NSDictionary]?
    var gamedates: NSDictionary?
    var gameDates = [String]()
    //    var parking: [String: Any]?
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEEEEE LLL dd h:mm aaa"
        print(dateFormatter.string(from: pickedDate!))
        
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
        
        // save parking data and set pins
        //        readFirebaseParkingData()
        
        // place the overlays in the correct places
        //        accessDataForOverlaysFromFirebase(pickedDate: now)
        accessDataForOverlays(pickedDate: now)
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
    
    // creates the zoom button
    lazy var settingsButton: UIButton = {
        let img = UIImage(named: "gear")
        let height_width: CGFloat = 30
        
        let button = UIButton(frame: CGRect(x: view.frame.width-navButtonW-xPadding, y: ynavPadding, width: height_width, height: height_width))
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
        //Source for title color:
        //https://stackoverflow.com/questions/31088172/how-to-set-the-title-text-color-of-uibutton/41853921
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


// Sources for this file:
// source for creating a UITextField programmatically: https://stackoverflow.com/questions/2728354/add-uitextfield-on-uiview-programmatically
// source for UI Date Picker View implementation: https://www.youtube.com/watch?v=aa-lNWUVY7g
// source for UI Text Field with rounded corners: https://stackoverflow.com/questions/13717007/uitextfield-rounded-corner-issue
// source for viewing annotation titles: https://stackoverflow.com/questions/37320485/swift-how-to-get-information-from-a-custom-annotation-on-clicked
// source for making annotations clickable: https://www.hackingwithswift.com/example-code/location/how-to-add-annotations-to-mkmapview-using-mkpointannotation-and-mkpinannotationview
// source for date range check: https://stackoverflow.com/questions/29652771/how-to-check-if-time-is-within-a-specific-range-in-swift/39499504#
// source for tomorrow date: https://stackoverflow.com/questions/44009804/swift-3-how-to-get-date-for-tomorrow-and-yesterday-take-care-special-case-ne
//source for linking view controllers: https://teamtreehouse.com/community/passing-data-from-modal-view-controller-to-parent
