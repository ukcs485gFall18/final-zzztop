//
//  ParkingDetailsViewController.swift
//  ios-midterm-2
//
//  Created by Kyra Seevers on 10/23/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

class ParkingDetailsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // links the Parking Details View Controller to the Map View Controller
        let vc = MapViewController(nibName: "MapViewController", bundle: nil)
        vc.detailsVC = self
        
        // setting the background of this current view to white
        view.backgroundColor = .white
        
        // declaring and adding a back button to the view
        let backButton = UIButton(frame: CGRect(x: 20, y: 50, width: 60, height: 30))
        backButton.layer.cornerRadius = 5
        backButton.backgroundColor = .blue
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        view.addSubview(backButton)
    }
    
    //-----------------------------------------------
    // closeView()
    //-----------------------------------------------
    // A function to close the current view upon
    // tapping the back button
    // Conditions: none
    //-----------------------------------------------
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //-----------------------------------------------
    // closeView()
    //-----------------------------------------------
    // The function that ties the MapViewController
    // to the ParkingDetailsViewController
    // Pre: Recieves the title of the pin and
    // a data structure containing the hours and pass
    // required for each parking spot
    // Post: Adds parking details to view in UIText
    //-----------------------------------------------
    func onUserAction(title: String, hours: [[String:String]: [NSDictionary]]) {
        // using a UITextView to enable multiline
        let textBox = UITextView(frame: CGRect(x: 30, y: 100, width: 400, height: 700))
        // sorting the key-value pairs by grouping
        let hoursSorted = hours.sorted(by: ==)
        // creating the text that will be displayed in the view
        var textToDisplay = ""
        
        // Dictionary of strings : array of NS Dictionaries
        for (key, value) in hoursSorted {
            // for each string pair in the dictionary (day range: pass)
            for (k,v) in key {
                textToDisplay += "Days: \(v)\nPass: \(k)\n"
            }
            
            var counter = 0
            
            // iterate through each hour set under the designated day and pass
            while(counter < value.count) {
                let set: NSDictionary = value[counter]
                let start = set.object(forKey: "start") as! NSDictionary
                let end = set.object(forKey: "end") as! NSDictionary
                
                // formatting the date to be user friendly
                textToDisplay += makeDateFromData(start: start, end: end)
                textToDisplay += "\n\n"
                counter += 1
            }
        }
        
        // write the name of the parking location
        textBox.text = ("Parking Location: \n\(title) \n\n\(textToDisplay)")
        // format the text box
        textBox.textColor = UIColor.black
        textBox.font = .systemFont(ofSize: 18)
        // ensure that no one can edit the UITextView
        textBox.isUserInteractionEnabled = false
        self.view.addSubview(textBox)
    }

    //-----------------------------------------------
    // makeDateFromData()
    //-----------------------------------------------
    // The function that formats the date to be
    // user friendly
    // Pre: Recieves the start and end NSDict
    // Post: Returns formatted string
    //-----------------------------------------------
    func makeDateFromData(start:NSDictionary, end:NSDictionary) -> String {
        let time = Date()
        
        // accesses the hour and minute for start and end
        let startHour = start["hour"] as! Int
        let startMinute = start["minute"] as! Int
        let startDate = time.dateAt(hours: startHour, minutes: startMinute)
        let endHour = end["hour"] as! Int
        let endMinute = end["minute"] as! Int
        
        // deals with time frames that are am to pm AND pm to am
        var endDate = Date()
        if end["12hour"] as! String  == "am" { // for pm-am/am-am (overnight parking)
            endDate = time.tomorrow(hour: endHour, minute: endMinute)
        } else { // for am-pm/pm-pm (same day)
            endDate = time.dateAt(hours: endHour, minutes: endMinute)
        }
        
        // formats the dates via a DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm aaa"
        return "From \(dateFormatter.string(from: startDate)) to \(dateFormatter.string(from: endDate))"
    }
    
}

// Sources for this file:
// source for font size: https://stackoverflow.com/questions/28742018/swift-increase-font-size-of-the-uitextview-how
// source for ViewController background: https://stackoverflow.com/questions/29759224/change-background-color-of-viewcontroller-swift-single-view-application/29759262

