//
//  ParkingDetailsViewController.swift
//  ios-midterm-2
//
//  Created by Kyra Seevers on 10/23/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

class ParkingDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - properties
    
    private var myTableView: UITableView!
    private var displayStrings = [String]()
    private var nameOfLocation = String()
    private var sortableStrings = [String: String]() // extracts the pass name and uses it as a key to sort
    private var sortedStrings = [(key: String, value: String)]() // dictionary of sorted strings for display in table, only use keys of the tuples
    var pickedDate: Date?
    var userPasses = [String]()
    var times = [[String: String]: [NSDictionary]]()
    let calendar = Calendar.current
    var availableRangeForSpot = [String: String]()
    var parkingName = String()
    let textBox = UITextView(frame: CGRect(x: 0, y: 0, width: 300, height: 80))
    
    //----------------------------------
    // Lazy vars for activity spinner
    //---------------------------------
    // https://teamtreehouse.com/community/how-do-you-have-an-activity-indicator-show-up-before-your-table-view-loads
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:100 ,y:200, width:50, height:50)) as UIActivityIndicatorView
        activityIndicatorView.center = self.view.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(activityIndicatorView)
        return activityIndicatorView
    }()

    lazy var activityLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: self.view.center.y+15, width: 125, height: 50))
        label.text = "Loading Details"
        label.textColor = .gray
        label.center.x = self.view.center.x
        self.view.addSubview(label)
        return label
    }()
    
    lazy var customView:UIView = {
        let customView:UIView = UIView(frame: CGRect(x:0, y: barHeight, width: self.view.frame.width, height: 80))
        customView.backgroundColor = UIColor(patternImage: UIImage(named: "teal-gradient.png")!)
        textBox.center.x = customView.center.x
        textBox.text = (nameOfLocation)
        textBox.textColor = UIColor.black
        textBox.font = .systemFont(ofSize: 20)
        textBox.backgroundColor = UIColor.clear
        // ensure that no one can edit the UITextView
        textBox.isUserInteractionEnabled = false
        customView.addSubview(textBox)
        customView.sizeToFit()
        customView.addSubview(backButton)
        return customView
    }()
    
    lazy var backButton:UIButton = {
        // declaring and adding a back button to the view
        let backButton = UIButton(frame: CGRect(x: 20, y: 25, width: 30, height: 30))
        backButton.layer.cornerRadius = 5
        //Reference: https://freakycoder.com/ios-notes-4-how-to-set-background-image-programmatically-b377a8d4b50f
        let backIcon = UIImage(named: "backIconBlack.png")
        backButton.setImage(backIcon, for: .normal)
        backButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        return backButton
    }()

    override func viewDidAppear(_ animated: Bool) {
        userPasses = UserDefaults.standard.array(forKey: "userPasses") as! [String]
        onUserAction(title: parkingName, hours: times)
        textBox.text = (nameOfLocation)
    }
    
    //-----------------------------------------------
    // viewWillAppear()
    //-----------------------------------------------
    // Sets conditions for loading data
    // Conditions: boolean for animated action
    //-----------------------------------------------
    override func viewWillAppear(_ animated: Bool) {
        myTableView.delegate = self
        myTableView.dataSource = self
        //so old data isn't presented to user
        activityIndicatorView.startAnimating() //show activity spinner until correct data loads in table
        activityLabel.isHidden = false
        myTableView.isHidden = true
    }
    
    //-----------------------------------------------
    // viewDidLoad()
    //-----------------------------------------------
    // Loads the UI views and links to MapViewController
    // Conditions: boolean for animated action
    //-----------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        // links the Parking Details View Controller to the Map View Controller
        let vc = MapViewController(nibName: "MapViewController", bundle: nil)
        vc.detailsVC = self

        // setting the background of this current view to white
        view.backgroundColor = .white

        // Created with help from https://stackoverflow.com/questions/40220905/create-uitableview-programmatically-in-swift
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height

        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight + customView.frame.height, width: displayWidth, height: displayHeight - barHeight - customView.frame.height))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        view.addSubview(customView)
    }
    
    //--------------------------------
    // TableView Delegate Functions
    //--------------------------------
    
    // Created with help from https://stackoverflow.com/questions/40220905/create-uitableview-programmatically-in-swift
    
    // displays the number of cells required to show all passes for that
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayStrings.count
    }

    // displays the strings of pass information in a table view cell per pass
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        // references: https://stackoverflow.com/questions/27762236/line-breaks-and-number-of-lines-in-swift-label-programmatically/27762296
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel!.text = "\(sortedStrings[indexPath.row].key)"
        // get the value from the tuple for the pass
        let passString = sortedStrings[indexPath.row].value
        // look in the dictionary of pass names and UIImages
        // put the value into the imageView
        let passImage = kPassImages[passString]
        cell.imageView?.image = passImage

        //highlights text different color depending on availability
        //if pass is a pass the user has
        if userPasses.contains(passString) {
            //if picked day is M, T, W, TR and text to be displayed in cell contains "Monday-Thursday", "Monday-Friday" or "All Week"
            if (calendar.component(.weekday, from: pickedDate!) - 1 == 1 || calendar.component(.weekday, from: pickedDate!) - 1 == 2 || calendar.component(.weekday, from: pickedDate!) - 1 == 3 || calendar.component(.weekday, from: pickedDate!) - 1 == 4) && (sortedStrings[indexPath.row].key.range(of: RangeStrings.MT.rawValue) != nil || sortedStrings[indexPath.row].key.range(of: RangeStrings.MF.rawValue) != nil || sortedStrings[indexPath.row].key.range(of: RangeStrings.MS.rawValue) != nil) {
                var waitTime: [NSDictionary]?
                //store start and ending dicts for correct range
                if times[[passString: "MT"]] != nil {
                    waitTime = times[[passString:"MT"]]!
                } else if times[[passString: "MF"]] != nil {
                    waitTime = times[[passString:"MF"]]!
                } else if times[[passString: "MS"]] != nil {
                    waitTime = times[[passString:"MS"]]!
                }
                //if there is an available range for this pass
                if availableRangeForSpot[passString] != nil {
                    //if the available range is in the text to be displayed
                    if (sortedStrings[indexPath.row].key.range(of: availableRangeForSpot[passString]!) != nil) {
                        //go through start and end dictionaries
                        //if picked date about to become unavailable in next hour highlight orange
                        //otherwise highlight green
                        for c in waitTime! {
                            let start = c["start"] as! NSDictionary
                            let end = c["end"] as! NSDictionary
                            let endHour = end["hour"] as! Int
                            let endMinute = end["minute"] as! Int
                            var endDate = Date()
                            if end["12hour"] as! String  == "am" && start["12hour"] as! String == "pm" {
                                endDate = pickedDate!.tomorrow(hour: endHour, minute: endMinute)
                                if pickedDate! > pickedDate!.dateAt(hours: 0, minutes: 0) && pickedDate! < pickedDate!.dateAt(hours: endHour, minutes: endMinute) {
                                    let hour = Calendar.current.component(.hour, from: pickedDate!)
                                    let minute = Calendar.current.component(.minute, from: pickedDate!)
                                    pickedDate! = pickedDate!.tomorrow(hour: hour, minute: minute)
                                }
                            } else { // same day parking
                                endDate = pickedDate!.dateAt(hours: endHour, minutes: endMinute)
                            }
                            // https://stackoverflow.com/questions/31298395/get-minutes-and-hours-between-two-nsdates?rq=1
                            let expire = endDate.timeIntervalSince(pickedDate!)
                            let formatter = DateComponentsFormatter()
                            formatter.unitsStyle = .abbreviated
                            if expire <= 3600 && expire > 0{
                                cell.textLabel!.text = cell.textLabel!.text! + "\nUnavailable in: " + formatter.string(from: expire)!
                                cell.textLabel!.highlightedTextColor = .orange
                                cell.textLabel!.isHighlighted = true
                            } else {
                                cell.textLabel!.highlightedTextColor = UIColor(red: 0.0353, green: 0.549, blue: 0, alpha: 1.0)
                                cell.textLabel!.isHighlighted = true
                            }
                        }
                    }
                }
                //if picked time is not in available range, check if it is becoming available in next 3 hours
                //if so highlight blue
                for c in waitTime! {
                    let start = c["start"] as! NSDictionary
                    let startHour = start["hour"] as! Int
                    let startMinute = start["minute"] as! Int
                    let startDate = pickedDate!.dateAt(hours: startHour, minutes: startMinute)
                    // https://stackoverflow.com/questions/31298395/get-minutes-and-hours-between-two-nsdates?rq=1
                    let delay = startDate.timeIntervalSince(pickedDate!)
                    let formatter = DateComponentsFormatter()
                    formatter.unitsStyle = .abbreviated
                    if startDate > pickedDate! && delay <= 10800 {
                        cell.textLabel!.text = cell.textLabel!.text! + "\nAvailable in: " + formatter.string(from: delay)!
                        cell.textLabel!.highlightedTextColor = .blue
                        cell.textLabel!.isHighlighted = true
                    }
                }
            // do similarly for friday and weekends
            } else if calendar.component(.weekday, from: pickedDate!) - 1 == 5 && (sortedStrings[indexPath.row].key.range(of: RangeStrings.MF.rawValue) != nil || sortedStrings[indexPath.row].key.range(of: RangeStrings.F.rawValue) != nil || sortedStrings[indexPath.row].key.range(of: RangeStrings.MS.rawValue) != nil) {
                var waitTime: [NSDictionary]?

                if times[[passString:"MF"]] != nil{
                    waitTime = times[[passString:"MF"]]!
                } else if times[[passString:"F"]] != nil{
                    waitTime = times[[passString:"F"]]!
                } else if times[[passString:"MS"]] != nil{
                    waitTime = times[[passString:"MS"]]!
                }

                if availableRangeForSpot[passString] != nil {
                    if (sortedStrings[indexPath.row].key.range(of: availableRangeForSpot[passString]!) != nil){
                        for c in waitTime! {
                            let start = c["start"] as! NSDictionary
                            let end = c["end"] as! NSDictionary
                            let endHour = end["hour"] as! Int
                            let endMinute = end["minute"] as! Int
                            var endDate = Date()
                            if end["12hour"] as! String  == "am" && start["12hour"] as! String == "pm" { // for pm-am/am-am (overnight parking)
                                endDate = pickedDate!.tomorrow(hour: endHour, minute: endMinute)
                            } else { // for am-pm/pm-pm (same day)
                                endDate = pickedDate!.dateAt(hours: endHour, minutes: endMinute)
                            }

                            // https://stackoverflow.com/questions/31298395/get-minutes-and-hours-between-two-nsdates?rq=1
                            let expire = endDate.timeIntervalSince(pickedDate!)
                            let formatter = DateComponentsFormatter()
                            formatter.unitsStyle = .abbreviated

                            if expire <= 3600 {
                                cell.textLabel!.text = cell.textLabel!.text! + "\nUnavailable in: " + formatter.string(from: expire)!
                                cell.textLabel!.highlightedTextColor = .orange
                                cell.textLabel!.isHighlighted = true
                            } else {
                                cell.textLabel!.highlightedTextColor = UIColor(red: 0.0353, green: 0.549, blue: 0, alpha: 1.0)
                                cell.textLabel!.isHighlighted = true
                            }
                        }
                    }

                    for c in waitTime! {
                        let start = c["start"] as! NSDictionary
                        let startHour = start["hour"] as! Int
                        let startMinute = start["minute"] as! Int
                        let startDate = pickedDate!.dateAt(hours: startHour, minutes: startMinute)
                        if startDate > pickedDate! {
                            let delay = startDate.timeIntervalSince(pickedDate!)
                            let formatter = DateComponentsFormatter()
                            formatter.unitsStyle = .abbreviated
                            cell.textLabel!.text = cell.textLabel!.text! + "\nAvailable in: " + formatter.string(from: delay)!
                            cell.textLabel!.highlightedTextColor = .red
                            cell.textLabel!.isHighlighted = true
                        }
                    }
                }
            } else if (calendar.component(.weekday, from: pickedDate!) - 1 == 0 || calendar.component(.weekday, from: pickedDate!) - 1 == 6) && (sortedStrings[indexPath.row].key.range(of: RangeStrings.SS.rawValue) != nil || sortedStrings[indexPath.row].key.range(of: RangeStrings.MS.rawValue) != nil) {
                var waitTime: [NSDictionary]?

                if times[[passString:"SS"]] != nil{
                    waitTime = times[[passString:"SS"]]!
                } else if times[[passString:"MS"]] != nil{
                    waitTime = times[[passString:"MS"]]!
                }

                if availableRangeForSpot[passString] != nil {
                    if (sortedStrings[indexPath.row].key.range(of: availableRangeForSpot[passString]!) != nil) {
                        for c in waitTime! {
                            let start = c["start"] as! NSDictionary
                            let end = c["end"] as! NSDictionary
                            let endHour = end["hour"] as! Int
                            let endMinute = end["minute"] as! Int
                            var endDate = Date()
                            if end["12hour"] as! String  == "am" && start["12hour"] as! String == "pm" { // for pm-am/am-am (overnight parking)
                                endDate = pickedDate!.tomorrow(hour: endHour, minute: endMinute)
                            } else { // for am-pm/pm-pm (same day)
                                endDate = pickedDate!.dateAt(hours: endHour, minutes: endMinute)
                            }
                            // https://stackoverflow.com/questions/31298395/get-minutes-and-hours-between-two-nsdates?rq=1
                            let expire = endDate.timeIntervalSince(pickedDate!)
                            let formatter = DateComponentsFormatter()
                            formatter.unitsStyle = .abbreviated
                            
                            if expire <= 3600 {
                                cell.textLabel!.text = cell.textLabel!.text! + "\nUnavailable in: " + formatter.string(from: expire)!
                                cell.textLabel!.highlightedTextColor = .orange
                                cell.textLabel!.isHighlighted = true
                            } else {
                                cell.textLabel!.highlightedTextColor = UIColor(red: 0.0353, green: 0.549, blue: 0, alpha: 1.0)
                                cell.textLabel!.isHighlighted = true
                            }
                        }
                    }
                }

                for c in waitTime! {
                    let start = c["start"] as! NSDictionary
                    let startHour = start["hour"] as! Int
                    let startMinute = start["minute"] as! Int
                    let startDate = pickedDate!.dateAt(hours: startHour, minutes: startMinute)
                    if startDate > pickedDate! {
                        let delay = startDate.timeIntervalSince(pickedDate!)
                        let formatter = DateComponentsFormatter()
                        formatter.unitsStyle = .abbreviated
                        cell.textLabel!.text = cell.textLabel!.text! + "\nAvailable in: " + formatter.string(from: delay)!
                        cell.textLabel!.highlightedTextColor = .red
                        cell.textLabel!.isHighlighted = true
                    }
                }
            }
        }
        return cell
    }

    // if the user selects a cell, take them to the UK transportation website
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // help from: https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        let parkHere = UIAlertController(title: "Alert", message: "Do you want to learn more?", preferredStyle: .alert)
        parkHere.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            switch action.style{
            case .default:
                // help regarding openURL being depricated in iOS10: https://useyourloaf.com/blog/openurl-deprecated-in-ios10/
                // open the URL in another Safari window
                let urlString = kPassURLs[self.sortedStrings[indexPath.row].value]
                if let url = URL(string: urlString!) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:],completionHandler: {
                            (successBool) in
                            if(!successBool){
                                print("Error opening \(urlString)")
                            }
                        })
                    } else {
                        let successBool = UIApplication.shared.openURL(url)
                        if(!successBool){
                            print("Error opening \(urlString)")
                        }
                    }
                }
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }}))

        // help from: https://stackoverflow.com/questions/25511945/swift-alert-view-ios8-with-ok-and-cancel-button-which-button-tapped
        // add the ability to say no and exit
        parkHere.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in parkHere.dismiss(animated: true, completion: nil)
        }))

        // add to screen
        self.present(parkHere, animated: true, completion: nil)

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
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
    // onUserAction()
    //-----------------------------------------------
    // The function that ties the MapViewController
    // to the ParkingDetailsViewController
    // Pre: Recieves the title of the pin and
    // a data structure containing the hours and pass
    // required for each parking spot
    // Post: Adds parking details to view in UIText
    //-----------------------------------------------
    func onUserAction(title: String, hours: [[String: String]: [NSDictionary]]) {
        // resetting all of the variables
        times = hours
        parkingName = title
        var textToDisplay = ""
        var pass = ""
        var range = ""
        displayStrings = [String]()
        sortableStrings = [String:String]()
        sortedStrings = [(key:String, value:String)]()

        // Dictionary of strings : array of NS Dictionaries
        for (key,value) in hours{
            // for each string pair in the dictionary (day range: pass)
            for (k,v) in key{
                let dayRange = formatDays(dayRange: v)
                textToDisplay += "Pass: \(k) \nDays: \(dayRange)\n"
                pass = k
                range = v
            }
            var counter = 0
            // iterate through each hour set under the designated day and pass
            while(counter < value.count) {
                let set: NSDictionary = value[counter]
                let start = set.object(forKey: "start") as! NSDictionary
                let end = set.object(forKey: "end") as! NSDictionary
                // formatting the date to be user friendly
                textToDisplay += makeDateFromData(start: start, end: end, pass: pass, range:range)
                displayStrings.append(textToDisplay)
                counter += 1
                textToDisplay = ""
            }
        }
        // write the name of the parking location
        nameOfLocation = ("   Parking Location: \n   \(title)")
        sortStrings()
        activityIndicatorView.stopAnimating()
        activityLabel.isHidden = true
        myTableView.reloadData()
        myTableView.isHidden = false
    }

    //-----------------------------------------------
    // makeDateFromData()
    //-----------------------------------------------
    // The function that formats the date to be
    // user friendly
    // Pre: Recieves the start and end NSDict
    // Post: Returns formatted string
    //-----------------------------------------------
    func makeDateFromData(start:NSDictionary, end:NSDictionary, pass:String, range:String) -> String {
        var time = pickedDate!

        // accesses the hour and minute for start and end
        let startHour = start["hour"] as! Int
        let startMinute = start["minute"] as! Int
        let startType = start["12hour"] as! String
        let startDate = time.dateAt(hours: startHour, minutes: startMinute)

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

        // formats the dates via a DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm aaa"

        let displayedRange = "From \(dateFormatter.string(from: startDate)) to \(dateFormatter.string(from: endDate))"
        
        //if picked date in range and picked date is pertains to the current range add the formatted text that will appear in cell to dictionary
        if ((calendar.component(.weekday, from: time) - 1 == 1 || calendar.component(.weekday, from: time) - 1 == 2 || calendar.component(.weekday, from: time) - 1 == 3 || calendar.component(.weekday, from: time) - 1 == 4) && (range == Range.mt.rawValue || range == Range.mf.rawValue || range == Range.ms.rawValue)) || ((calendar.component(.weekday, from: time) - 1 == 5) && (range == Range.f.rawValue || range == Range.ms.rawValue)) || ((calendar.component(.weekday, from: time) - 1 == 0 ||  calendar.component(.weekday, from: time) - 1 == 6) && (range == Range.ss.rawValue || range == Range.ms.rawValue)){
            if time >= startDate && time <= endDate {
                availableRangeForSpot[pass] = displayedRange
            }
            //if not in range and there is something in the dictionary remove it from dictioanry
            else if availableRangeForSpot[pass] != nil {
                availableRangeForSpot.removeValue(forKey: pass)
            }
        }
        
        return displayedRange
    }


    // for each enum return the raw value
    func formatDays(dayRange: String) -> String {
        switch dayRange{
        case "MF":
            return RangeStrings.MF.rawValue
        case "MT":
            return RangeStrings.MT.rawValue
        case "F":
            return RangeStrings.F.rawValue
        case "SS":
            return RangeStrings.SS.rawValue
        case "MS":
            return RangeStrings.MS.rawValue
        default:
            return "No date"
        }
    }

    //-----------------------------------------------
    // sortStrings()
    //-----------------------------------------------
    // Parses each string in displayStrings array to
    // get the pass, trim whitespaces, and sort the
    // strings alphabetically by pass
    // Conditions: None
    //-----------------------------------------------
    func sortStrings() {
        for string in displayStrings {
            let parkingInfoArray = string.components(separatedBy: "\n")
            let passInfo = parkingInfoArray[0] //get the first line
            let passNoColonArray = passInfo.components(separatedBy: ": ")
            //Ensure no trailing whitespaces
            let nameOfPass = passNoColonArray[1].trimmingCharacters(in: .whitespaces)
            sortableStrings[string] = nameOfPass
        }
        sortedStrings = sortableStrings.sorted(by: { $0.value < $1.value })
    }

    // Sources for this file:
    // source for font size: https://stackoverflow.com/questions/28742018/swift-increase-font-size-of-the-uitextview-how
    // source for ViewController background: https://stackoverflow.com/questions/29759224/change-background-color-of-viewcontroller-swift-single-view-application/29759262
    // reference for trimming whitespace: https://www.hackingwithswift.com/example-code/strings/how-to-trim-whitespace-in-a-string

}
