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
    private var sortableStrings = [String:String]() //extracts the pass name and uses it as a key to sort
    private var sortedStrings = [(key:String, value:String)]() //dictionary of sorted strings for display in table, only use keys of the tuples
    //private var passImages = [String:UIImage]()
    var pickedDate: Date?
    var userPasses = [String]()
    var times = [[String: String]: [NSDictionary]]()
    let calendar = Calendar.current
    var availableRangeForSpot = [String:Bool]()
    var parkingName = String()
    
    enum rangeStrings: String {
        case MF = "Monday - Friday"
        case MT = "Monday - Thursday"
        case F = "Friday"
        case SS = "Saturday - Sunday"
        case MS = "All Week"
    }
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:100 ,y:200, width:50, height:50)) as UIActivityIndicatorView
        activityIndicatorView.center = self.view.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(activityIndicatorView)
        return activityIndicatorView
    }()
    
    lazy var activityLabel :UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: self.view.center.y+15, width: 125, height: 50))
        label.text = "Loading Details"
        label.textColor = .gray
        label.center.x = self.view.center.x
        self.view.addSubview(label)
        return label
    }()

    override func viewDidAppear(_ animated: Bool) {
        userPasses = UserDefaults.standard.array(forKey: "userPasses") as! [String]
        onUserAction(title: parkingName, hours: times)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myTableView.delegate = self
        myTableView.dataSource = self
        activityIndicatorView.startAnimating()
        activityLabel.isHidden = false
        myTableView.isHidden = true
    }
    //Created with help from https://stackoverflow.com/questions/40220905/create-uitableview-programmatically-in-swift
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayStrings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        //references: https://stackoverflow.com/questions/27762236/line-breaks-and-number-of-lines-in-swift-label-programmatically/27762296
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel!.text = "\(sortedStrings[indexPath.row].key)"
        //get the value from the tuple for the pass
        let passString = sortedStrings[indexPath.row].value
        //look in the dictionary of pass names and UIImages
        //put the value into the imageView
        let passImage = kPassImages[passString]
        cell.imageView?.image = passImage
        
        if userPasses.contains(passString) {
            if (calendar.component(.weekday, from: pickedDate!) - 1 == 1 || calendar.component(.weekday, from: pickedDate!) - 1 == 2 || calendar.component(.weekday, from: pickedDate!) - 1 == 3 || calendar.component(.weekday, from: pickedDate!) - 1 == 4) && (sortedStrings[indexPath.row].key.range(of: rangeStrings.MT.rawValue) != nil || sortedStrings[indexPath.row].key.range(of: rangeStrings.MF.rawValue) != nil || sortedStrings[indexPath.row].key.range(of: rangeStrings.MS.rawValue) != nil) {
                for key in availableRangeForSpot.keys {
                    if (sortedStrings[indexPath.row].key.range(of: key) != nil){
                        cell.textLabel!.highlightedTextColor = .blue
                        cell.textLabel!.isHighlighted = true
                        break
                    }
                }
                var waitTime: [NSDictionary]?
                if times[[passString:"MT"]] != nil{
                    waitTime = times[[passString:"MT"]]!
                }
                else if times[[passString:"MF"]] != nil{
                    waitTime = times[[passString:"MF"]]!
                }
                else if times[[passString:"MS"]] != nil{
                    waitTime = times[[passString:"MS"]]!
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
            else if calendar.component(.weekday, from: pickedDate!) - 1 == 5 && (sortedStrings[indexPath.row].key.range(of: rangeStrings.MF.rawValue) != nil || sortedStrings[indexPath.row].key.range(of: rangeStrings.F.rawValue) != nil || sortedStrings[indexPath.row].key.range(of: rangeStrings.MS.rawValue) != nil) {
                for key in availableRangeForSpot.keys {
                    if (availableRangeForSpot[key]! && sortedStrings[indexPath.row].key.range(of: key) != nil){
                        cell.textLabel!.highlightedTextColor = .blue
                        cell.textLabel!.isHighlighted = true
                        break
                    }
                    var waitTime: [NSDictionary]?
                    if times[[passString:"MF"]] != nil{
                        waitTime = times[[passString:"MF"]]!
                    }
                    else if times[[passString:"F"]] != nil{
                        waitTime = times[[passString:"F"]]!
                    }
                    else if times[[passString:"MS"]] != nil{
                        waitTime = times[[passString:"MS"]]!
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
            else if (calendar.component(.weekday, from: pickedDate!) - 1 == 0 || calendar.component(.weekday, from: pickedDate!) - 1 == 6) && (sortedStrings[indexPath.row].key.range(of: rangeStrings.SS.rawValue) != nil || sortedStrings[indexPath.row].key.range(of: rangeStrings.MS.rawValue) != nil) {
                for key in availableRangeForSpot.keys {
                    if (sortedStrings[indexPath.row].key.range(of: key) != nil){
                        cell.textLabel!.highlightedTextColor = .blue
                        cell.textLabel!.isHighlighted = true
                    }
                }
                var waitTime: [NSDictionary]?
                if times[[passString:"SS"]] != nil{
                    waitTime = times[[passString:"SS"]]!
                }
                else if times[[passString:"MS"]] != nil{
                    waitTime = times[[passString:"MS"]]!
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print(displayStrings.count)
        print("Value: \(displayStrings[indexPath.row])")
        
        //help from: https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        let parkHere = UIAlertController(title: "Alert", message: "Do you want to learn more?", preferredStyle: .alert)
        parkHere.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            switch action.style{
            case .default:
                //help regarding openURL being depricated in iOS10:
                //https://useyourloaf.com/blog/openurl-deprecated-in-ios10/
                //let urlString = "https://www.uky.edu/transportation/2018_student_commuter"
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
        
        //help from: https://stackoverflow.com/questions/25511945/swift-alert-view-ios8-with-ok-and-cancel-button-which-button-tapped
        parkHere.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in parkHere.dismiss(animated: true, completion: nil)
        }))
        
        self.present(parkHere, animated: true, completion: nil)
        
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
        
        //Created with help from https://stackoverflow.com/questions/40220905/create-uitableview-programmatically-in-swift
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: 90, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        
        //declaring and adding a back button to the view
        let backButton = UIButton(frame: CGRect(x: 20, y: 50, width: 30, height: 30))
        backButton.layer.cornerRadius = 5
        //backButton.backgroundColor = .blue
        //Reference: https://freakycoder.com/ios-notes-4-how-to-set-background-image-programmatically-b377a8d4b50f
        let backIcon = UIImage(named: "backIconBlack.png")
        backButton.setImage(backIcon, for: .normal)
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
    // onUserAction()
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
        //resetting all of the variables
        times = hours
        parkingName = title
        var textToDisplay = ""
        displayStrings = [String]()
        sortableStrings = [String:String]()
        sortedStrings = [(key:String, value:String)]()
        
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
    func makeDateFromData(start:NSDictionary, end:NSDictionary) -> String{
        let time = pickedDate!
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
        
        let displayedRange = "From \(dateFormatter.string(from: startDate)) to \(dateFormatter.string(from: endDate))"
        if pickedDate! >= startDate && pickedDate! <= endDate {
            availableRangeForSpot[displayedRange] = true
        }
        return displayedRange
    }
    
    
    func formatDays(dayRange: String) -> String{
        switch dayRange{
        case "MF":
            return rangeStrings.MF.rawValue
        case "MT":
            return rangeStrings.MT.rawValue
        case "F":
            return rangeStrings.F.rawValue
        case "SS":
            return rangeStrings.SS.rawValue
        case "MS":
            return rangeStrings.MS.rawValue
        default:
            return "No date"
        }
    }
    
    func sortStrings(){
        for string in displayStrings{
            let parkingInfoArray = string.components(separatedBy: "\n")
            let passInfo = parkingInfoArray[0] //get the first line
            let passNoColonArray = passInfo.components(separatedBy: ": ")
            let nameOfPass = passNoColonArray[1].trimmingCharacters(in: .whitespaces)
            print(nameOfPass)
            sortableStrings[string] = nameOfPass
        }
        sortedStrings = sortableStrings.sorted(by: { $0.value < $1.value })
    }
    
    //Sources for this file:
    //source for font size: https://stackoverflow.com/questions/28742018/swift-increase-font-size-of-the-uitextview-how
    //source for ViewController background: https://stackoverflow.com/questions/29759224/change-background-color-of-viewcontroller-swift-single-view-application/29759262
    //reference for trimming whitespace: https://www.hackingwithswift.com/example-code/strings/how-to-trim-whitespace-in-a-string
    
}
