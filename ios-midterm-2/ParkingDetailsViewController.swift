//
//  ParkingDetailsViewController.swift
//  ios-midterm-2
//
//  Created by Adrienne Corwin on 10/22/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

class ParkingDetailsViewController: UIViewController {
    var pTitle:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textBox =  UITextField(frame: CGRect(x: 20, y: 100, width: 300, height: 40))
        textBox.text = pTitle
        textBox.textColor = UIColor.white
        let textBox2 =  UITextField(frame: CGRect(x: 30, y: 100, width: 300, height: 40))
        textBox2.text = "Hello World"
        textBox2.textColor = UIColor.white
        self.view.addSubview(textBox2)
    }

}
