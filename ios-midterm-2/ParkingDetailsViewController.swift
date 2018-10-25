//
//  ParkingDetailsViewController.swift
//  ios-midterm-2
//
//  Created by Kyra Seevers on 10/23/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

class ParkingDetailsViewController: UIViewController {

    var passedTitle:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = MapViewController(nibName: "MapViewController", bundle: nil)
        vc.detailsVC = self
        
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
    }
    
    func onUserAction(title: String, hours: [String: [NSDictionary]])
    {
        //using a UITextView to enable multiline
        let textBox =  UITextView(frame: CGRect(x: 30, y: 100, width: 400, height: 700))
        var textToDisplay = ""
        for (key,value) in hours{
            textToDisplay += key
            textToDisplay += ": "
            var counter = 0
            while(counter < value.count){
                let set:NSDictionary = value[counter]
                let start = set.object(forKey: "start") as! NSDictionary
                let end = set.object(forKey: "end") as! NSDictionary
                textToDisplay += makeDateFromData(start: start, end: end)
                textToDisplay += "\n"
                counter+=1
            }
        }
        textBox.text = ("Parking Location: \n\(title) \nHours: \n\(textToDisplay)")
        textBox.textColor = UIColor.black
        textBox.font = .systemFont(ofSize: 16)
        //ensure that no one can edit the UITextView
        textBox.isUserInteractionEnabled = false
        self.view.addSubview(textBox)
    }

    func makeDateFromData(start:NSDictionary, end:NSDictionary) -> String{
        let time = Date()
        let startHour = start["hour"] as! Int
        let startMinute = start["minute"] as! Int
        let startDate = time.dateAt(hours: startHour, minutes: startMinute)
        let endHour = end["hour"] as! Int
        let endMinute = end["minute"] as! Int
        
        var endDate = Date()
        if end["12hour"] as! String  == "am" { // for pm-am/am-am (overnight parking)
            endDate = time.tomorrow(hour: endHour, minute: endMinute)
        } else { // for am-pm/pm-pm (same day)
            endDate = time.dateAt(hours: endHour, minutes: endMinute)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm aaa"
        return "From \(dateFormatter.string(from: startDate)) to \(dateFormatter.string(from: endDate))"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //source for font size: https://stackoverflow.com/questions/28742018/swift-increase-font-size-of-the-uitextview-how
    //source for ViewController background: https://stackoverflow.com/questions/29759224/change-background-color-of-viewcontroller-swift-single-view-application/29759262
    
}
