//
//  Constants.swift
//  ios-midterm-2
//
//  Created by Adrienne Corwin on 10/21/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit
import Firebase

let kPassTypes = [
    "E", "E2", "E20", "E25", "E26", "E28", "E27",
    "R2", "R7", "R17", "R19", "R29", "R30",
    "C5", "C9", "C16",
    "K", "EK", "CK", "X",
    "Authorized parking only", "Any valid permit", "No permit required"
]

let EPassImage = UIImage(named: "EPass.png")
let E2PassImage = UIImage(named: "E2.png")
let E20PassImage = UIImage(named: "E20.png")
let E25PassImage = UIImage(named: "E25.png")
let E26PassImage = UIImage(named: "E26.png")
let E28PassImage = UIImage(named: "E28.png")
let E27PassImage = UIImage(named: "E27.png")
let R2PassImage = UIImage(named: "R2.png")
let R7PassImage = UIImage(named: "R7.png")
let R17PassImage = UIImage(named: "R17.png")
let R19PassImage = UIImage(named: "R19.png")
let R29PassImage = UIImage(named: "R29.png")
let R30PassImage = UIImage(named: "R30.png")
let C5PassImage = UIImage(named: "C5.png")
let C9PassImage = UIImage(named: "C9.png")
let C16PassImage = UIImage(named: "C16.png")
var KPassImage = UIImage(named: "K.png")
let EKPassImage = UIImage(named: "EK.png")
let CKPassImage = UIImage(named: "CK.png")
let XPassImage = UIImage(named: "X.png")
let AuthorizedPassImage = UIImage(named: "Auth.png")
let AnyPassImage = UIImage(named: "Any.png")
let NoPassImage = UIImage(named: "No.png")

let kPassURLs = [
    "E": "https://www.uky.edu/transportation/parking-permits_employee-permits",
    "E2": "https://www.uky.edu/transportation/parking-permits_employee-permits",
    "E20": "https://www.uky.edu/transportation/parking-permits_employee-permits",
    "E25": "https://www.uky.edu/transportation/parking-permits_employee-permits",
    "E26": "https://www.uky.edu/transportation/parking-permits_employee-permits",
    "E28": "https://www.uky.edu/transportation/parking-permits_employee-permits",
    "E27": "https://www.uky.edu/transportation/parking-permits_employee-permits",
    "R2": "https://www.uky.edu/transportation/2018_student_residential",
    "R7": "https://www.uky.edu/transportation/2018_student_residential",
    "R17": "https://www.uky.edu/transportation/2018_student_residential",
    "R19": "https://www.uky.edu/transportation/2018_student_remote",
    "R29": "https://www.uky.edu/transportation/2018_student_residential",
    "R30": "https://www.uky.edu/transportation/2018_student_residential",
    "C5": "https://www.uky.edu/transportation/2018_student_commuter",
    "C9": "https://www.uky.edu/transportation/2018_student_commuter",
    "C16": "https://www.uky.edu/transportation/2018_student_commuter",
    "K": "https://www.uky.edu/transportation/2018_student_periphery",
    "EK": "https://www.uky.edu/transportation/parking-permits_employee-permits",
    "CK": "https://www.uky.edu/transportation/2018_student_commuter",
    "X": "https://www.uky.edu/transportation/2018_student_remote",
    "Authorized parking only": "https://www.uky.edu/transportation/parking-info_parking-regulations#restrictedparking",
    "Any valid permit": "https://uknow.uky.edu/student-and-academic-life/uk-parking-permit-enforcement-dates",
    "No permit required": "https://www.uky.edu/transportation/parking-info_visitor-parking"
]

let kPassImages = [
    "E": EPassImage,
    "E2": E2PassImage,
    "E20": E20PassImage,
    "E25": E25PassImage,
    "E26": E26PassImage,
    "E28": E28PassImage,
    "E27": E27PassImage,
    "R2": R2PassImage,
    "R7": R7PassImage,
    "R17": R17PassImage,
    "R19": R19PassImage,
    "R29": R29PassImage,
    "R30": R30PassImage,
    "C5": C5PassImage,
    "C9": C9PassImage,
    "C16": C16PassImage,
    "K": KPassImage,
    "EK": EKPassImage,
    "CK": CKPassImage,
    "X": XPassImage,
    "Authorized parking only": AuthorizedPassImage,
    "Any valid permit": AnyPassImage,
    "No permit required": NoPassImage
    ] as! [String: UIImage]

let kDurationHours = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"]

let xPadding: CGFloat = 10
let yPadding: CGFloat = 10
let ynavPadding: CGFloat = 5
let navButtonW: CGFloat = 50
let navButtonH: CGFloat = 25
let headerHeight: CGFloat = 50
let buttonHeight: CGFloat = 50
let buttonWidth: CGFloat = 100
let bottomPadding: CGFloat = 30
let headerFontSize: CGFloat = 25
let regFontSize: CGFloat = 20

let barHeight = UIApplication.shared.statusBarFrame.size.height

// enum of all pass types
enum PassType: String {
    case e = "E"
    case e2 = "E2"
    case e20 = "E20"
    case e25 = "E25"
    case e26 = "E26"
    case e28 = "E28"
    case e27 = "E27"
    case r2 = "R2"
    case r7 = "R7"
    case r17 = "R17"
    case r19 = "R19"
    case r29 = "R29"
    case r30 = "R30"
    case c5 = "C5"
    case c9 = "C9"
    case c16 = "C16"
    case k = "K"
    case ek = "EK"
    case ck = "CK"
    case x = "X"
    case a = "Authorized parking only"
    case anyPermit = "Any valid permit"
    case noPermitRequired = "No permit required"
}

// enum of all possible weekdays
enum WeekDay: String {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
}

// enum of all date ranges
enum Range: String {
    case mt = "MT" // Monday-Thursday
    case mf = "MF" // Monday-Friday
    case ss = "SS" // Saturday-Sunday
    case f = "F" // Friday
    case ms = "MS" // Monday-Sunday
}

enum gameDay: String {
    case tomorrow = "Tomorrow"
    case today = "Today"
    case none = "None"
}

enum RangeStrings: String {
    case MF = "Monday - Friday"
    case MT = "Monday - Thursday"
    case F = "Friday"
    case SS = "Saturday - Sunday"
    case MS = "All Week"
}

// colors
let red = UIColor(red: 250/255, green: 92/255, blue: 71/255, alpha: 1) // matches the logo
let lightblue = UIColor(red: 196/255, green: 191/255, blue: 227/255, alpha: 1) // matches the logo
let darkerAppleBlue = UIColor(red: 9/255, green: 100/255, blue: 255/255, alpha: 1)
let lightgray = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)

// AddParkingViewController
let tfHeight = CGFloat(40)
let separation = CGFloat(12)
let tfFontSize = CGFloat(20)

// Firebase
let databaseRef = Database.database().reference()
