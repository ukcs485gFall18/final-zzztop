//
//  Extensions.swift
//  ios-midterm-2
//
//  Created by Jordan George on 12/10/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

extension Date {
    
    func dateAt(hours: Int, minutes: Int) -> Date {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        var date_components = calendar.components(
            [NSCalendar.Unit.year,
             NSCalendar.Unit.month,
             NSCalendar.Unit.day],
            from: self)
        
        date_components.hour = hours
        date_components.minute = minutes
        date_components.second = 0
        
        let newDate = calendar.date(from: date_components)!
        
        return newDate
    }
    
    // get date for tomorrow
    func tomorrow(hour: Int, minute: Int) -> Date {
        let time = Calendar.current.date(bySettingHour: hour, minute: minute, second: 59, of: self)! // misses 1 second
        return Calendar.current.date(byAdding: .day, value: 1, to: time)!
    }
    
}

extension UITextField {
    
    func setBottomBorder(color: UIColor) {
        self.borderStyle = UITextField.BorderStyle.none
        self.backgroundColor = UIColor.clear
        
        let line = UIView()
        let height = 1.0
        line.frame = CGRect(x: 0, y: Double(self.frame.height) - height, width: Double(self.frame.width), height: height)
        line.backgroundColor = color
        
        self.addSubview(line)
    }
    
}
