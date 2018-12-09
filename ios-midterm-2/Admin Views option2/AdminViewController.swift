//
//  adminview2.swift
//  ios-midterm-2
//
//  Created by Jordan George on 12/4/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit
import Static
import SwiftyJSON

class AdminViewController: TableViewController, UITextFieldDelegate {
    
    // MARK: - properties
    
    //    var tag = Int()
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
    var times:[String:Any]?
    //    var selectedTimes:[String:Any]?
    
    // MARK: - initializers
    
    convenience init() {
        self.init(style: .grouped)
    }
    
    // MARK: - overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        
        
        
        
        
        
        
        
        
        getJson()
        //        print(json["parking"][0]["name"])
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options:[])
            // here "jsonData" is the dictionary encoded in JSON data
            
            let outString = String(data:jsonData, encoding:.utf8)
            
            print("outString = \(outString)")
            let url = saveJsonToFile("sample", outString: outString! )
            print(url)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    func saveJsonToFile (_ fileName:String, outString: String) -> URL {
        let docDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileURL = docDirectory?.appendingPathComponent(fileName).appendingPathExtension("json") {
            print("fileURL = \(fileURL)")
            // Write to a file on disk
            
            do {
                try outString.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }
            return fileURL
        }
        return URL(string: "")!
    }
    var json = JSON()
    func getJson() {
        let filename = "parkingData2"
        let path = Bundle.main.path(forResource: filename, ofType: "json")!
        let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
        json = JSON(parseJSON: jsonString!)
        //        print(json)
        //        print(json["parking"][0]["name"])
    }
    
    
    
    
    
    
    
    
    
    @objc func submit() {
        //        let values = JSON([
        //            "name": "Columbia Ave East Lot2",
        //            "radius": 70,
        //            "coords":  [
        //                "lat": 38.033142,
        //                "lon": -84.50028
        //            ]
        //        ])
        // add data to json file
        //        print(values["name"])
        //        let updated = try? json.merge(with: values)
        //        print(updated)
    }
    override func viewDidAppear(_ animated: Bool) {
        //         UserDefaults.standard.set([], forKey: "coords") // testing
        
        // check if the user is logged in before allowing the user to make any admin changes
        checkIfUserIsLoggedIn()
        
        getCoords()
        
        str = ""
        str2 = ""
        str3 = ""
        makeDayOptionsIntoString()
        
        // designs and positions views
        setUpViews()
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
    
    
    
    func checkIfUserIsLoggedIn() {
        // for testing
        //        UserDefaults.standard.set("wrong", forKey: "username")
        //        UserDefaults.standard.set("wrong", forKey: "password")
        
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
        UserDefaults.standard.set("", forKey: "username")
        UserDefaults.standard.set("", forKey: "password")
        present(LoginViewController2(), animated: true, completion: nil)
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
        ]
        
        view.addSubview(submitButton)
        setUpSubmitButton()
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

