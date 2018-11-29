//
//  ParkingDetailsViewController.swift
//  ios-midterm-2
//
//  Created by Kyra Seevers on 10/23/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

class ParkingDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var myTableView: UITableView!
    private var displayStrings = [String]()
    private var nameOfLocation = String()
    
    //Created with help from https://stackoverflow.com/questions/40220905/create-uitableview-programmatically-in-swift
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayStrings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        //references: https://stackoverflow.com/questions/27762236/line-breaks-and-number-of-lines-in-swift-label-programmatically/27762296
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel!.text = "\(displayStrings[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print(displayStrings.count)
        print("Value: \(displayStrings[indexPath.row])")
    }
    
    //created with help from: https://stackoverflow.com/questions/38139774/how-to-set-a-custom-cell-as-header-or-footer-of-uitableview
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let customView:UIView = UIView()
        customView.backgroundColor = UIColor(patternImage: UIImage(named: "teal-gradient.png")!)
        
        let textBox =  UITextView(frame: CGRect(x: 0, y: 0, width: 450, height: 70))
        textBox.text = (nameOfLocation)
        textBox.textColor = UIColor.black
        textBox.font = .systemFont(ofSize: 20)
        textBox.backgroundColor = UIColor.clear
        //ensure that no one can edit the UITextView
        textBox.isUserInteractionEnabled = false
        customView.addSubview(textBox)
        customView.sizeToFit()
        return customView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //links the Parking Details View Controller to the Map View Controller
        let vc = MapViewController(nibName: "MapViewController", bundle: nil)
        vc.detailsVC = self
        
        //setting the background of this current view to white
        view.backgroundColor = .white
        
        //declaring and adding a back button to the view
        let backButton = UIButton(frame: CGRect(x: 20, y: 50, width: 60, height: 30))
        backButton.layer.cornerRadius = 5
        //backButton.backgroundColor = .blue
        //Reference: https://freakycoder.com/ios-notes-4-how-to-set-background-image-programmatically-b377a8d4b50f
        let backIcon = UIImage(named: "backIcon.png")
        backButton.setImage(backIcon, for: .normal)
        backButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        view.addSubview(backButton)
        
        //Created with help from https://stackoverflow.com/questions/40220905/create-uitableview-programmatically-in-swift
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: 90, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        
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
    func onUserAction(title: String, hours: [[String:String]: [NSDictionary]])
    {
        //sorting the key-value pairs by grouping
        //let hoursSorted = hours.sorted(by: ==)
        //creating the text that will be displayed in the view
        var textToDisplay = ""
        displayStrings = [String]()
        //Dictionary of strings : array of NS Dictionaries
        for (key,value) in hours{
            //for each string pair in the dictionary (day range: pass)
            for (k,v) in key{
                let dayRange = formatDays(dayRange: v)
                textToDisplay += "Pass: \(k) \nDays: \(dayRange)\n"
            }
            var counter = 0
            //iterate through each hour set under the designated day and pass
            while(counter < value.count){
                let set:NSDictionary = value[counter]
                let start = set.object(forKey: "start") as! NSDictionary
                let end = set.object(forKey: "end") as! NSDictionary
                //formatting the date to be user friendly
                textToDisplay += makeDateFromData(start: start, end: end)
                displayStrings.append(textToDisplay)
                counter+=1
                textToDisplay = ""
            }
        }
        //write the name of the parking location
        nameOfLocation = ("   Parking Location: \n   \(title)")
        print(title)
        myTableView.reloadData()
        for string in displayStrings{
            print(string)
        }
    }

    //-----------------------------------------------
    // makeDateFromData()
    //-----------------------------------------------
    // The function that formats the date to be
    // user friendly
    // Pre: Recieves the start and end NSDict
    // Post: Returns formatted string
    //-----------------------------------------------
    func makeDateFromData(start:NSDictionary, end:NSDictionary) -> String{
        let time = Date()
        //accesses the hour and minute for start and end
        let startHour = start["hour"] as! Int
        let startMinute = start["minute"] as! Int
        let startDate = time.dateAt(hours: startHour, minutes: startMinute)
        let endHour = end["hour"] as! Int
        let endMinute = end["minute"] as! Int
        
        //deals with time frames that are am to pm AND pm to am
        var endDate = Date()
        if end["12hour"] as! String  == "am" { // for pm-am/am-am (overnight parking)
            endDate = time.tomorrow(hour: endHour, minute: endMinute)
        } else { // for am-pm/pm-pm (same day)
            endDate = time.dateAt(hours: endHour, minutes: endMinute)
        }
        //formats the dates via a DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm aaa"
        return "From \(dateFormatter.string(from: startDate)) to \(dateFormatter.string(from: endDate))"
    }

    func formatDays(dayRange: String) -> String{
        switch dayRange{
        case "MF":
            return "Monday - Friday"
        case "MT":
            return "Monday - Thursday"
        case "F":
            return "Friday"
        case "SS":
            return "Saturday - Sunday"
        case "MS":
            return "All Week"
        default:
            return "No date"
        }
    }
    
    //Sources for this file:
    //source for font size: https://stackoverflow.com/questions/28742018/swift-increase-font-size-of-the-uitextview-how
    //source for ViewController background: https://stackoverflow.com/questions/29759224/change-background-color-of-viewcontroller-swift-single-view-application/29759262
    
}
