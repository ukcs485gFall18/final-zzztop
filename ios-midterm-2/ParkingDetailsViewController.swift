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
        
        let textBox =  UITextField(frame: CGRect(x: 30, y: 100, width: 300, height: 100))
        textBox.text = ("Hello \(passedTitle)")
        textBox.textColor = UIColor.white
        let textBox2 =  UITextField(frame: CGRect(x: 30, y: 300, width: 300, height: 100))
        textBox2.text = "Hello World"
        textBox2.textColor = UIColor.white
        
        self.view.addSubview(textBox2)
        // Do any additional setup after loading the view.
    }
    
    func onUserAction(title: String, hours: String)
    {
        let textBox =  UITextView(frame: CGRect(x: 30, y: 100, width: 400, height: 700))
        textBox.text = ("Parking Location: \n\(title) \nHours: \n\(hours)")
        textBox.textColor = UIColor.white
        textBox.backgroundColor = UIColor.black
        self.view.addSubview(textBox)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
