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
    
    func onUserAction(title: String, hours: [String:[Any]])
    {
        //using a UITextView to enable multiline
        let textBox =  UITextView(frame: CGRect(x: 30, y: 100, width: 400, height: 700))
        textBox.text = ("Parking Location: \n\(title) \nHours: \n\(hours)")
        textBox.textColor = UIColor.black
        textBox.font = .systemFont(ofSize: 16)
        //ensure that no one can edit the UITextView
        textBox.isUserInteractionEnabled = false
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

    //source for font size: https://stackoverflow.com/questions/28742018/swift-increase-font-size-of-the-uitextview-how
    //source for ViewController background: https://stackoverflow.com/questions/29759224/change-background-color-of-viewcontroller-swift-single-view-application/29759262
    
}
