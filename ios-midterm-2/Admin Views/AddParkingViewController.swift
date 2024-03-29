//
//  adminview2.swift
//  ios-midterm-2
//
//  Created by Jordan George on 12/4/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import Static

class AddParkingViewController: TableViewController, UITextFieldDelegate {
    
    // MARK: - properties
    
    var tag = Int()
    var name: String?
    var radius: Int?
    var passtype:String?
    var coords: [String: Double]?
    var coordDisplay = String()
    var dayOptions = [
        ["MT", "F", "SS"],
        ["MF", "SS"],
        ["MS"]
    ]
    var times: [String? : [String : [String : [String : Any]]]]?
    
    // MARK: - initializers
    
    // for Static
    convenience init() {
        self.init(style: .grouped)
    }
    
    // MARK: - overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // check if the user is logged in before allowing the user to make any admin changes
        checkIfUserIsLoggedIn()
        
        getCoords()
        
        setTempTimes()
        
        str = ""
        str2 = ""
        str3 = ""
        makeDayOptionsIntoString()
        
        // designs and positions views
        setUpViews()
    }
    
    func getCoords() {
        guard let tempCoords = UserDefaults.standard.dictionary(forKey: "coords") as? [String : Double] else { return }
        
        coords = tempCoords
        
        if coords!.isEmpty {
            coordDisplay = "no coordinates selected"
        } else {
            let lat = (coords!["lat"])!
            let lon = (coords!["lon"])!
            coordDisplay = "\(lat), \(lon)"
        }
        
        vc.coords = coords
    }
    
    func setTempTimes() {
        guard let passtype = vc.passtype else { return }
        vc.times = [
            passtype: [
                "MT": [
                    "start": [
                        "hour": 19,
                        "minute": 30,
                        "12hour": "pm"
                    ],
                    "end": [
                        "hour": 5,
                        "minute": 0,
                        "12hour": "am"
                    ]
                ],
                "F": [
                    "start": [
                        "hour": 15,
                        "minute": 30,
                        "12hour": "pm"
                    ],
                    "end": [
                        "hour": 23,
                        "minute": 59,
                        "12hour": "pm"
                    ]
                ],
                "SS": [
                    "start": [
                        "hour": 0,
                        "minute": 0,
                        "12hour": "am"
                    ],
                    "end": [
                        "hour": 23,
                        "minute": 59,
                        "12hour": "pm"
                    ]
                ]
            ]
        ]
    }
    
    // submit data entered into fields to firebase
    // uses temporary data for the "times" key
    @objc func submitToFirebase() {
        guard let name = vc.name,
            let radius = vc.radius,
            let coords = vc.coords,
            let times = vc.times else { return }
        
        
        let values: [String: Any] = [
            "radius": radius,
            "coords":  coords,
            "times": times
        ]
        
        // add data to firebase
        databaseRef.child("parking").child(name).setValue(values)
        
        // dismiss view
        navigationController?.popViewController(animated: true)
    }
    
    var str = ""
    var str2 = ""
    var str3 = ""
    func makeDayOptionsIntoString() {
        for day in dayOptions[0] {
            if day ==  dayOptions[0].last {
                str += day
            } else {
                str += day + ", "
            }
        }
        for day in dayOptions[1] {
            if day ==  dayOptions[1].last {
                str2 += day
            } else {
                str2 += day + ", "
            }
        }
        for day in dayOptions[2] {
            if day ==  dayOptions[2].last {
                str3 += day
            } else {
                str3 += day + ", "
            }
        }
    }
    
    func checkIfUserIsLoggedIn() {
        let attemptedUsername = UserDefaults.standard.string(forKey: "username")
        let attemptedPassword = UserDefaults.standard.string(forKey: "password")
        let rightUsername = "Admin"
        let rightPassword = "123"
        
        if attemptedUsername != rightUsername || attemptedPassword != rightPassword {
            present(LoginViewController(), animated: true, completion: nil)
        } else {
            return
        }
    }
    
    // logout the user
    @objc func logout() {
        // reset user defaults
        UserDefaults.standard.set("", forKey: "username")
        UserDefaults.standard.set("", forKey: "password")
        
        // present login
        present(LoginViewController(), animated: true, completion: nil)
    }
    
    // MARK: - views
    
    // designs and positions views
    func setUpViews() {
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        navigationItem.rightBarButtonItem = logoutButton
        
        title = "Add New Parking Spot"
        
        tableView.rowHeight = 50
        
        // Required to be set pre iOS11, to support autosizing
        tableView.estimatedSectionHeaderHeight = 13.5
        tableView.estimatedSectionFooterHeight = 13.5
        
        dataSource = DataSource(tableViewDelegate: self)
        dataSource.sections = [
            Section(rows: [
                Row(text: "Name:", cellClass: regularTextFieldCell.self),
                Row(text: "Radius:", cellClass: radiusPickerTextFieldCell.self),
                Row(text: "Coordinates: \(coordDisplay)", selection: { [unowned self] in
                    self.navigationController?.pushViewController(AdminMapViewController(), animated: true)
                    }, accessory: .disclosureIndicator),
                ]),
            Section(rows: [
                Row(text: "Pass Type:", cellClass: passPickerTextFieldCell.self)
                ]),
            Section(header: "Days", rows: [
                Row(text: str, selection: { [unowned self] in
                    chooseDayVC.options = self.dayOptions[0]
                    self.navigationController?.pushViewController(ChooseDayViewController(), animated: true)
                    }, accessory: .disclosureIndicator),
                Row(text: str2,  selection: { [unowned self] in
                    chooseDayVC.options = self.dayOptions[1]
                    self.navigationController?.pushViewController(ChooseDayViewController(), animated: true)
                    }, accessory: .disclosureIndicator),
                Row(text: str3, selection: { [unowned self] in
                    chooseDayVC.options = self.dayOptions[2]
                    self.navigationController?.pushViewController(ChooseDayViewController(), animated: true)
                    }, accessory: .disclosureIndicator)
                ], footer: "Choose days for which you'd like to enter times.")
//            ,Section(rows: [
//                Row(cellClass: submitButtonCell.self)
//                ])
        ]
        
        view.addSubview(submitButton)
        setUpSubmitButton()
    }
    
    // create submit button
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = darkerAppleBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 23)
        button.addTarget(self, action: #selector(submitToFirebase), for: .touchUpInside)
        return button
    }()
    
    // position submit button
    func setUpSubmitButton() {
        submitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        submitButton.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        submitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 200).isActive = true // does not work as expected
    }
    
}

//----------------
//later:
//- save data entered to user defaults JIC the admin accidentally taps the exit button; but not with logout button
//- How to let multiplier be fraction constant var
//- refactor cells with tag functionality
//- swift global var rules? (like vc in this case)
