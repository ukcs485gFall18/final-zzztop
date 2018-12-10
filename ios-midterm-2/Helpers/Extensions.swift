//
//  Extensions.swift
//  ios-midterm-2
//
//  Created by Jordan George on 12/10/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit
import Static

// for LoginViewController
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

// for static
extension TableViewController: UITableViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {}
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
}
