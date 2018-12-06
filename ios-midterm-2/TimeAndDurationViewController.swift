//
//  TimeAndDurationViewController.swift
//  ios-midterm-2
//
//  Created by Kyra Seevers on 12/5/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

class TimeAndDurationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var pickedDate: Date?
    var timePicked:Int = 0
    var didSelectDate: Bool = false
    let now = Date()
    var pickerTextField = UITextField()
    var timePickerTextField = UITextField()
    let datePicker = UIDatePicker()
    let timePicker = UIPickerView()
    var mapViewController:MapViewController?
  
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return kDurationHours.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return kDurationHours[row]
    }
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timePickerTextField.text = kDurationHours[row] + " hours"
        timePicked = Int(kDurationHours[row])!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting the background of this current view to white
        view.backgroundColor = UIColor.lightGray
        
        let pleaseSelect = UITextView(frame: CGRect(x: 0, y: buttonHeight+60, width: view.frame.width-buttonWidth, height: 65))
        pleaseSelect.text = "Please select the day and time \n you want to park:"
        pleaseSelect.center.x = view.center.x
        pleaseSelect.font = UIFont.systemFont(ofSize: regFontSize)
        pleaseSelect.layer.cornerRadius = 5
        pleaseSelect.textAlignment = .center
        pleaseSelect.isEditable = false
        self.view.addSubview(pleaseSelect)
        
        pickerTextField = UITextField(frame: CGRect(x: 0, y: buttonHeight+yPadding+70+60, width: view.frame.width-buttonWidth, height: buttonHeight))
        pickerTextField.center.x = view.center.x
        pickerTextField.textAlignment = NSTextAlignment.center
        pickerTextField.font = UIFont.systemFont(ofSize: regFontSize)
        pickerTextField.backgroundColor = .white
        pickerTextField.textColor = .black
        pickerTextField.borderStyle = UITextField.BorderStyle.none
        pickerTextField.layer.cornerRadius = 5
        
        let pleaseSelectTime = UITextView(frame: CGRect(x: 0, y: (2*buttonHeight)+(2*yPadding)+100+60, width: view.frame.width-buttonWidth, height: 65))
        pleaseSelectTime.text = "Please select the duration \n you want to park:"
        pleaseSelectTime.center.x = view.center.x
        pleaseSelectTime.font = UIFont.systemFont(ofSize: regFontSize)
        pleaseSelectTime.layer.cornerRadius = 5
        pleaseSelectTime.textAlignment = .center
        pleaseSelectTime.isEditable = false
        self.view.addSubview(pleaseSelectTime)
        
        timePickerTextField = UITextField(frame: CGRect(x: 0, y: (2*buttonHeight)+(2*yPadding)+180+60, width: view.frame.width-buttonWidth, height: buttonHeight))
        timePickerTextField.center.x = view.center.x
        timePickerTextField.textAlignment = NSTextAlignment.center
        timePickerTextField.font = UIFont.systemFont(ofSize: regFontSize)
        timePickerTextField.backgroundColor = .white
        timePickerTextField.textColor = .black
        timePickerTextField.borderStyle = UITextField.BorderStyle.none
        timePickerTextField.layer.cornerRadius = 5
        
        createPickerView()
        pickedDate = now
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEEEEE LLL d h:mm aaa"
        pickerTextField.text = dateFormatter.string(from: pickedDate!)
        timePickerTextField.text = "Current times only: 0 hours"
        
        //declaring and adding a back button to the view
        let backButton = UIButton(frame: CGRect(x: 20, y: 50, width: 30, height: 30))
        backButton.layer.cornerRadius = 5
        //backButton.backgroundColor = .blue
        //Reference: https://freakycoder.com/ios-notes-4-how-to-set-background-image-programmatically-b377a8d4b50f
        let backIcon = UIImage(named: "backIconBlack.png")
        backButton.setImage(backIcon, for: .normal)
        backButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        view.addSubview(backButton)
        
        // Do any additional setup after loading the view.
    }
    
    
    //-----------------------------------------------
    // createPickerView()
    //-----------------------------------------------
    // A function to create the UIPickerView and
    // place it on the view
    // Conditions: none
    //-----------------------------------------------
    func createPickerView() {
        view.addSubview(pickerTextField)
        view.addSubview(timePickerTextField)
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(MapViewController.dateSelected(datePicker:)), for: .valueChanged)
        // add the DatePicker to the UITextField
        pickerTextField.inputView = datePicker
        
        timePicker.dataSource = self
        timePicker.delegate = self
        timePickerTextField.inputView = timePicker
        
        // allow the user to get out of the date picker by tapping
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MapViewController.tapToLeave(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    //-----------------------------------------------
    // tapToLeave()
    //-----------------------------------------------
    // allows the user to leave the UI picker by
    // tapping elsewhere
    // Conditions: none
    //-----------------------------------------------
    @objc func tapToLeave(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
        didSelectDate = true
    }
    
    //-----------------------------------------------
    // closeView()
    //-----------------------------------------------
    // A function to close the current view upon
    // tapping the back button
    // Conditions: none
    //-----------------------------------------------
    @objc func closeView() {
        self.dismiss(animated: true, completion:{
            self.mapViewController?.accessDataForOverlays(pickedDate: self.pickedDate!)
        })
    }
    
    //-----------------------------------------------
    // dateSelected()
    //-----------------------------------------------
    // formats the date selected and places it into
    // the UI Text Field
    // Post: accesses the data to set the pins
    // to match the new date
    //-----------------------------------------------
    @objc func dateSelected(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEEEEE LLL d h:mm aaa"
        pickerTextField.text = dateFormatter.string(from: datePicker.date)
        
        pickedDate = datePicker.date
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
     //source for int casting: https://stackoverflow.com/questions/24115141/converting-string-to-int-with-swift
    
}
