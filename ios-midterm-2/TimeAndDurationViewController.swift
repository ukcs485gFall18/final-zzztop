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
    var timePicked: Int = 0
    let now = Date()
    var pickerTextField = UITextField()
    var timePickerTextField = UITextField()
    let datePicker = UIDatePicker()
    let timePicker = UIPickerView()
    var mapViewController: MapViewController?
    var fromAdminPanel: Bool = false
    var settingsViewController: SettingsViewController?

    //-----------------------------------
    // UI Picker View Delegate Functions
    //-----------------------------------

    //only one set of into in the picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    //number of options is equal to the number of hours in the duration array
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return kDurationHours.count
    }

    //fill the table view with the hours in the duration array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return kDurationHours[row] + " hours"
    }

    //save the number of hours they selected
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timePickerTextField.text = kDurationHours[row] + " hours"
        timePicked = Int(kDurationHours[row])!
        //adding the duration to the date
        var addingHours = DateComponents()
        addingHours.hour = self.timePicked
        let futureTime = Calendar.current.date(byAdding: addingHours, to: self.pickedDate!)
        //send the formatted date to the mapViewController
        self.mapViewController?.dateSelected(datePicked: futureTime!)
    }

    //-----------------------------------------------
    // viewDidLoad()
    //-----------------------------------------------
    // A function to load the two pickers and buttons
    // Conditions: none
    //-----------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        //setting the background of this current view to white
        view.backgroundColor = UIColor.lightGray

        //instructions for the date picker
        let pleaseSelect = UITextView(frame: CGRect(x: 0, y: buttonHeight+60, width: view.frame.width-buttonWidth, height: 65))
        pleaseSelect.text = "Please select the day and time \n you want to park:"
        pleaseSelect.center.x = view.center.x
        pleaseSelect.font = UIFont.systemFont(ofSize: regFontSize)
        pleaseSelect.layer.cornerRadius = 5
        pleaseSelect.textAlignment = .center
        pleaseSelect.isEditable = false
        pleaseSelect.sizeToFit()
        let fixedWidth = CGFloat(view.frame.width-buttonWidth)
        let newSize = pleaseSelect.sizeThatFits(CGSize(width: fixedWidth, height: pleaseSelect.frame.height))
        pleaseSelect.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        self.view.addSubview(pleaseSelect)

        //create the text field housing the date picker
        pickerTextField = UITextField(frame: CGRect(x: 0, y: buttonHeight+yPadding+70+70, width: view.frame.width-buttonWidth, height: buttonHeight))
        pickerTextField.center.x = view.center.x
        pickerTextField.textAlignment = NSTextAlignment.center
        pickerTextField.font = UIFont.systemFont(ofSize: regFontSize)
        pickerTextField.backgroundColor = .white
        pickerTextField.textColor = .black
        pickerTextField.borderStyle = UITextField.BorderStyle.none
        pickerTextField.layer.cornerRadius = 5

        //instructions for the time picker
        let pleaseSelectTime = UITextView(frame: CGRect(x: 0, y: (2*buttonHeight)+(2*yPadding)+100+60, width: view.frame.width-buttonWidth, height: 65))
        pleaseSelectTime.text = "Please select the duration \n you want to park:"
        pleaseSelectTime.center.x = view.center.x
        pleaseSelectTime.font = UIFont.systemFont(ofSize: regFontSize)
        pleaseSelectTime.layer.cornerRadius = 5
        pleaseSelectTime.textAlignment = .center
        pleaseSelectTime.isEditable = false
        let fixedWidth2 = CGFloat(view.frame.width-buttonWidth)
        let newSize2 = pleaseSelectTime.sizeThatFits(CGSize(width: fixedWidth2, height: pleaseSelectTime.frame.height))
        pleaseSelectTime.frame.size = CGSize(width: max(newSize2.width, fixedWidth2), height: newSize2.height)
        self.view.addSubview(pleaseSelectTime)

        //create the text field housing the time/duration picker
        timePickerTextField = UITextField(frame: CGRect(x: 0, y: (2*buttonHeight)+(2*yPadding)+180+70, width: view.frame.width-buttonWidth, height: buttonHeight))
        timePickerTextField.center.x = view.center.x
        timePickerTextField.textAlignment = NSTextAlignment.center
        timePickerTextField.font = UIFont.systemFont(ofSize: regFontSize)
        timePickerTextField.backgroundColor = .white
        timePickerTextField.textColor = .black
        timePickerTextField.borderStyle = UITextField.BorderStyle.none
        timePickerTextField.layer.cornerRadius = 5

        //create the date picker view and format the dates
        createPickerView()
        pickedDate = now
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEEEEE LLL d h:mm aaa"
        pickerTextField.text = dateFormatter.string(from: pickedDate!)
//        timePickerTextField.text = "Current times only: 0 hours"
//        timePickerTextField.text = "Current times only: " + kDurationHours[0] + " hours"
        timePickerTextField.text = "\(kDurationHours[0]) hours"

        // declaring and adding a back button to the view
        let backButton = UIButton(frame: CGRect(x: 20, y: 50, width: 30, height: 30))
        backButton.layer.cornerRadius = 5
        // backButton.backgroundColor = .blue
        // Reference: https://freakycoder.com/ios-notes-4-how-to-set-background-image-programmatically-b377a8d4b50f
        let backIcon = UIImage(named: "backIconBlack.png")
        backButton.setImage(backIcon, for: .normal)
        backButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        view.addSubview(backButton)
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

        //for the date picker
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(dateSelected(datePicker:)), for: .valueChanged)
        // add the DatePicker to the UITextField
        pickerTextField.inputView = datePicker

        //for the time/duration picker
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
    }

    //-----------------------------------------------
    // closeView()
    //-----------------------------------------------
    // A function to close the current view upon
    // tapping the back button
    // Conditions: none
    //-----------------------------------------------
    @objc func closeView() {
        if (self.fromAdminPanel) {
            if let vc = self.presentingViewController {
                vc.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        //dismiss the view
        self.dismiss(animated: true, completion: nil)
    }

    //-----------------------------------------------
    // dateSelected()
    //-----------------------------------------------
    // formats the date selected and places it into
    // the UI Text Field
    // Post: accesses the data to set the pins
    // to match the new date
    //-----------------------------------------------
    @objc func dateSelected(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEEEEE LLL d h:mm aaa"
        pickerTextField.text = dateFormatter.string(from: datePicker.date)

        //send the formatted date to the mapViewController
        self.mapViewController?.dateSelected(datePicked: datePicker.date)
    }


    // source for int casting: https://stackoverflow.com/questions/24115141/converting-string-to-int-with-swift
    // source for adding hours to a date: http://swiftdeveloperblog.com/code-examples/add-days-months-or-years-to-current-date-in-swift/
}
