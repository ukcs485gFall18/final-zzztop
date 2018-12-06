//
//  adminview2.swift
//  ios-midterm-2
//
//  Created by Jordan George on 12/4/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit
import Static

class AdminViewController: TableViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    //    var tag = Int()
    var name: String?
    var radius: Int?
    var passtype:String?
    var coords: [String: Double]?
    var coordDisplay = String()
    
    // MARK: - Initializers
    
    //    do i need?
    convenience init() {
        self.init(style: .grouped)
    }
    
    // MARK: - viewdidload
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//         UserDefaults.standard.set([], forKey: "coords") // testing
        
        // check if the user is logged in before allowing the user to make any admin changes
        checkIfUserIsLoggedIn()
        
        getCoords()
        
        setupViews()
    }
    
    func getCoords() {
        guard let tempcoords = UserDefaults.standard.dictionary(forKey: "coords") as? [String : Double] else {return}
        coords = tempcoords
        if coords!.isEmpty {
            coordDisplay = "no coordinates selected"
        } else {
            let lat = (coords!["lat"])!
            let lon = (coords!["lon"])!
            coordDisplay = "\(lat), \(lon)"
        }
        vc.coords = coords
    }
    
    @objc func submit() {
        guard let name = vc.name,
            let radius = vc.radius,
            //            let passtype = vc.passtype,
            let coords = vc.coords else { return }
        
        
        let values: [String: Any] = [
            "radius": radius,
            "coords":  coords,
            "times": [
                "No permit required": [
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
                ],
                "Any valid permit": [
                    "MT": [
                        "start": [
                            "hour": 15,
                            "minute": 30,
                            "12hour": "pm"
                        ],
                        "end": [
                            "hour": 19,
                            "minute": 30,
                            "12hour": "pm"
                        ]
                    ]
                ],
                "E": [
                    "MF": [
                        "start": [
                            "hour": 5,
                            "minute": 0,
                            "12hour": "am"
                        ],
                        "end": [
                            "hour": 15,
                            "minute": 30,
                            "12hour": "pm"
                        ]
                    ]
                ]
            ]
        ]
        
        // add data to firebase
        databaseRef.child("parking").child(name).setValue(values)
        
        // dismiss view
        navigationController?.popViewController(animated: true)
    }
    
    func checkIfUserIsLoggedIn() {
        // for testing
        //                UserDefaults.standard.set("wrong", forKey: "username")
        //                UserDefaults.standard.set("wrong", forKey: "password")
        
        let pastUsername = UserDefaults.standard.string(forKey: "username")
        let pastPassword = UserDefaults.standard.string(forKey: "password")
        let rightUsername = "Admin"
        let rightPassword = "123"
        
        if pastUsername != rightUsername || pastPassword != rightPassword {
            present(LoginViewController2(), animated: true, completion: nil)
        } else {
            return
        }
    }
    
    @objc func logout() {
        present(LoginViewController2(), animated: true, completion: nil)
    }
    
    func setupViews() {
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
                Row(text: "Pass Type:", cellClass: passPickerTextFieldCell.self)
                ]),
            Section(header: "Map", rows: [
                Row(text: "Coordinates: \(coordDisplay)", selection: { [unowned self] in
                    self.navigationController?.pushViewController(AdminMapViewController(), animated: true)
                    }, accessory: .disclosureIndicator)
                ]),
            Section(header: "Days", rows: [
                Row(text: "Start Time:", cellClass: timesPickerTextFieldCell.self),
                Row(text: "End Time:", cellClass: timesPickerTextFieldCell.self)
                ])
            //            ,
            //            Section(rows: [
            //                Row(cellClass: submitbuttoncell.self)
            //                ])
        ]
        
        view.addSubview(submitButton)
        setupSubmitButton()
    }
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = darkerAppleBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(submit), for: .touchUpInside)
        return button
    }()
    
    func setupSubmitButton() {
        submitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        submitButton.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        submitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40).isActive = true // does not work as expected
    }
    
}


// TODO:
//    1.Day options
//    2.Fill out times in text views that have picker views


// options for adding dates and times:
//option 1
//    "MT"
//    "F"
//    "SS"
//option 2
//    "MF"
//    "SS"
//option 3
//    "MS"
// create another view?
// forces admin to have times for every day

//----------------
//later:
//- save data entered to user defaults JIC the admin accidentally taps the exit button; but not with logout button
//- How to let multiplier be fraction constant var
