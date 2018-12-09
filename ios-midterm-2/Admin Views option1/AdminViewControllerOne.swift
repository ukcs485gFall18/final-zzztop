//
//  AdminViewController.swift
//  ios-midterm-2
//
//  Created by Jordan George on 11/30/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

class AdminViewControllerOne: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // check if the user is logged in before allowing the user to make any admin changes
        checkIfUserIsLoggedIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    @objc func submit() {
        let name = "Columbia Ave East Lot2" // fake data; temp
        let values: [String: Any] = [ // fake data; temp
            "radius": 70,
            "coords":  [
                "lat": 38.033142,
                "lon": -84.50028
            ],
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
//        databaseRef.child("parking").child(name).setValue(values)
        
        // dismiss view
        
    }
    
    @objc func logout() {
        present(LoginViewController1(), animated: true, completion: nil)
    }
    
    
    func checkIfUserIsLoggedIn() {
        // for testing
//        UserDefaults.standard.set("wrong", forKey: "username")
//        UserDefaults.standard.set("wrong", forKey: "password")
        
        let pastUsername = UserDefaults.standard.string(forKey: "username")
        let pastPassword = UserDefaults.standard.string(forKey: "password")
        let rightUsername = "Admin"
        let rightPassword = "123"
        
        if pastUsername != rightUsername || pastPassword != rightPassword {
            present(LoginViewController1(), animated: true, completion: nil)
        } else {
            return
        }
    }
    
    
    // redundant?
    @objc func tapToLeave(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    
    // MARK: - text field config
    
    var activeTextField = UITextField()
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // picker view config
        if textField == radiusTextField {
            pickerView.tag = 0
        } else if textField == startTextField {
            pickerView.tag = 1
        } else if textField == endTextField {
            pickerView.tag = 2
        }
        pickerView.reloadAllComponents()
        
        // create bottom border
        // temporary, keeps adding subviews instead of removing
        activeTextField.setBottomBorder(color: UIColor.white)
        activeTextField = textField
        activeTextField.setBottomBorder(color: red)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // temporary, need to remove subview
        activeTextField.setBottomBorder(color: UIColor.white)
    }
    
    // Hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // Switch focus to next text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        usernameTextField.resignFirstResponder()
//
//        if textField == usernameTextField {
//            passwordTextField.becomeFirstResponder()
//        } else if textField == passwordTextField {
//            passwordTextField.resignFirstResponder()
//        }
        
        return true
    }
    
    
    // MARK: - picker view protocol config
    
    let radiusItems = Array(65...75)
    let timeItems: [[Any]] = [
        Array(1...12), // hours
        [0, 30, 59], // minutes
        ["AM", "PM"] // am/pm
    ]
    
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 0 {
            return 1
        } else {
            return 3
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return radiusItems.count
        } else {
            if component == 0 {
                return timeItems[0].count
            } else if component == 1 {
                return timeItems[1].count
            } else {
                return timeItems[2].count
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return "\(row + radiusItems[0])"
        } else {
            if component == 0 {
                let text = timeItems[0][row]
                return "\(text)"
            } else if component == 1 {
                let text = timeItems[1][row]
                return "\(text)"
            } else {
                let text = timeItems[2][row]
                return "\(text)"
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            radiusTextField.text = "\(radiusItems[row])"
        } else {
            var hour = Int()
            var min = Int()
            var ampm = String()
            
            if component == 0 {
                hour = timeItems[0][row] as! Int
            } else if component == 1 {
                min = timeItems[1][row] as! Int
            } else {
                ampm = timeItems[2][row] as! String
            }
            
            startTextField.text = "\(hour) \(min) \(ampm)"
        }
    }
    
    
    // MARK: - views
    
    func setUpViews() {
        view.backgroundColor = .white
        
        view.addSubview(nameTextField)
        view.addSubview(radiusTextField)
        view.addSubview(latTextField)
        view.addSubview(lonTextField)
        view.addSubview(daySegmentedControl)
        view.addSubview(startTextField)
        view.addSubview(endTextField)
        view.addSubview(submitButton)
        
        setUpNameTextField()
        setUpRadiusTextField()
        setUpLatTextField()
        setUpLonTextField()
        setUpDaySegmentedControl()
        setUpStartTextField()
        setUpEndTextField()
        setUpSubmitButton()
        
        // picker view configuration
        radiusTextField.inputView = pickerView
        startTextField.inputView = pickerView
        endTextField.inputView = pickerView
        
        // sets first value shown in picker view to middle of picker view items
        let row = radiusItems.count / 2
        pickerView.selectRow(row, inComponent: 0, animated: true)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AdminViewControllerOne.tapToLeave(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = "Name"
        textField.backgroundColor = UIColor.white
        textField.tintColor = red
        textField.font = UIFont.systemFont(ofSize: tfFontSize)
        return textField
    }()
    
    func setUpNameTextField() {
        nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: tfHeight).isActive = true
    }
    
    lazy var radiusTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = "Radius"
        textField.backgroundColor = UIColor.white
        textField.tintColor = red
        textField.font = UIFont.systemFont(ofSize: tfFontSize)
        return textField
    }()
    
    func setUpRadiusTextField() {
        radiusTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        radiusTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: separation).isActive = true
        radiusTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5).isActive = true
        radiusTextField.heightAnchor.constraint(equalToConstant: tfHeight).isActive = true
    }
    
    // TODO: add coords label
    // TODO: setUp for label
    
    lazy var latTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = "Latitude"
        textField.backgroundColor = UIColor.white
        textField.tintColor = red
        textField.font = UIFont.systemFont(ofSize: tfFontSize)
        return textField
    }()
    
    func setUpLatTextField() {
        latTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        latTextField.topAnchor.constraint(equalTo: radiusTextField.bottomAnchor, constant: separation).isActive = true
        latTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5).isActive = true
        latTextField.heightAnchor.constraint(equalToConstant: tfHeight).isActive = true
    }
    
    lazy var lonTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = "Longitude"
        textField.backgroundColor = UIColor.white
        textField.tintColor = red
        textField.font = UIFont.systemFont(ofSize: tfFontSize)
        return textField
    }()
    
    func setUpLonTextField() {
        lonTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lonTextField.topAnchor.constraint(equalTo: latTextField.bottomAnchor, constant: separation).isActive = true
        lonTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5).isActive = true
        lonTextField.heightAnchor.constraint(equalToConstant: tfHeight).isActive = true
    }
    
    // TODO: get coords by pressing on map
    // lat and lon tfs would then be labels and show coords
    // with map showing location
    
    // FIXME: Multi selection segmented control
    var daySegmentedControl: UISegmentedControl = {
        let items = [
            Range.mt.rawValue,
            Range.mf.rawValue,
            Range.f.rawValue,
            Range.ms.rawValue,
            Range.ss.rawValue
        ]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    func setUpDaySegmentedControl() {
        daySegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        daySegmentedControl.topAnchor.constraint(equalTo: lonTextField.bottomAnchor, constant: separation).isActive = true
        daySegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5).isActive = true
        daySegmentedControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    lazy var startTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = "Start"
        textField.backgroundColor = UIColor.white
        textField.tintColor = red
        textField.font = UIFont.systemFont(ofSize: tfFontSize)
        return textField
    }()
    
    func setUpStartTextField() {
        startTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startTextField.topAnchor.constraint(equalTo: daySegmentedControl.bottomAnchor, constant: separation).isActive = true
        startTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5).isActive = true
        startTextField.heightAnchor.constraint(equalToConstant: tfHeight).isActive = true
    }
    
    lazy var endTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = "End"
        textField.backgroundColor = UIColor.white
        textField.tintColor = red
        textField.font = UIFont.systemFont(ofSize: tfFontSize)
        return textField
    }()
    
    func setUpEndTextField() {
        endTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        endTextField.topAnchor.constraint(equalTo: startTextField.bottomAnchor, constant: separation).isActive = true
        endTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5).isActive = true
        endTextField.heightAnchor.constraint(equalToConstant: tfHeight).isActive = true
    }
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = darkerAppleBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Submit", for: .normal)
        button.layer.cornerRadius = 5.0
        button.addTarget(self, action: #selector(submit), for: .touchUpInside)
        return button
    }()
    
    func setUpSubmitButton() {
        submitButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    
    
}

// add pass options; picker view of all passes

// FIXME: Start and end time picker view are connected; need to unconnect

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
