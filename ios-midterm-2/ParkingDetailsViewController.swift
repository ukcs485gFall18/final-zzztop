//
//  ParkingDetailsViewController.swift
//  ios-midterm-2
//
//  Created by Adrienne Corwin on 10/22/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

class ParkingDetailsViewController: UIViewController {
    var pTitle=String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textBox =  UITextField(frame: CGRect(x: 20, y: 100, width: 300, height: 40))
        textBox.text = "Hello World"
        textBox.textColor = UIColor.white
        self.view.addSubview(textBox)
    }

}
