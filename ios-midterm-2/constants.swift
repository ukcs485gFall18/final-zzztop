//
//  Constants.swift
//  ios-midterm-2
//
//  Created by Adrienne Corwin on 10/21/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

let kPassTypes = [
    "E", "E2", "E20", "E26", "E28", "E27",
    "R2", "R7", "R17", "R19", "R29", "R30",
    "C5", "C9", "C16",
    "K", "EK", "CK", "X",
    "Authorized parking only", "Any valid permit", "No permit required"
]

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

// colors
let red = UIColor(red: 250/255, green: 92/255, blue: 71/255, alpha: 1) // matches the logo
let lightblue = UIColor(red: 196/255, green: 191/255, blue: 227/255, alpha: 1) // matches the logo
let darkerAppleBlue = UIColor(red: 9/255, green: 100/255, blue: 255/255, alpha: 1)
let lightgray = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)

// AdminViewController
let tfHeight = CGFloat(40)
let separation = CGFloat(12)
let tfFontSize = CGFloat(20)
