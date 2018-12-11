//
//  TicketsViewController.swift
//  ios-midterm-2
//
//  Created by Kyra Seevers on 12/9/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

class TicketsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ticketsArray = [String]()
    var ticketsArrayRetrieved = [String]()
    private var myTableView: UITableView!
    var textField = UITextField()
    let datePicker = UIDatePicker()
    var didSelectDate: Bool = false
    let defaults = UserDefaults.standard
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ticketsArrayRetrieved = defaults.object(forKey: "TicketsArray") as? [String] ?? [String]()
        return ticketsArrayRetrieved.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        //references: https://stackoverflow.com/questions/27762236/line-breaks-and-number-of-lines-in-swift-label-programmatically/27762296
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel!.text = "\(ticketsArrayRetrieved[indexPath.row])"
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting the background of this current view to white
        view.backgroundColor = .white
        
        //Created with help from https://stackoverflow.com/questions/40220905/create-uitableview-programmatically-in-swift
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: 90, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        
        //declaring and adding a back button to the view
        let backButton = UIButton(frame: CGRect(x: 20, y: 50, width: 30, height: 30))
        backButton.layer.cornerRadius = 5
        let backIcon = UIImage(named: "backIconBlack.png")
        backButton.setImage(backIcon, for: .normal)
        backButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        view.addSubview(backButton)
        
        //declaring and adding a back button to the view
        let plusButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width-50, y: 50, width: 30, height: 30))
        plusButton.layer.cornerRadius = 5
        let plusIcon = UIImage(named: "Plus.png")
        plusButton.setImage(plusIcon, for: .normal)
        plusButton.addTarget(self, action: #selector(createNewTicket), for: .touchUpInside)
        view.addSubview(plusButton)
    }
    
    //-----------------------------------------------
    // closeView()
    //-----------------------------------------------
    // A function to close the current view upon
    // tapping the back button
    // Conditions: none
    //-----------------------------------------------
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func createNewTicket(){
        let addDueDate = UIAlertController(title: "Alert", message: "When is your ticket due?", preferredStyle: .alert)
        addDueDate.addTextField { (textField) in
            textField.text = "Enter pay by date here"
        }
        addDueDate.addAction(UIAlertAction(title: "Submit", style: .default, handler: { action in
            switch action.style{
            case .default:
                self.createPickerView()
                var newTicket = "Created: "
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEEEEEE LLL d yyyy"
                newTicket = newTicket + dateFormatter.string(from: Date())
                self.textField = addDueDate.textFields![0]
                newTicket = newTicket+"\nDue: "+self.textField.text!
                self.ticketsArrayRetrieved = self.defaults.object(forKey: "TicketsArray") as? [String] ?? [String]()
                self.ticketsArrayRetrieved.append(newTicket)
                self.defaults.set(self.ticketsArrayRetrieved, forKey: "TicketsArray")
                self.myTableView.reloadData()
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }}))
        
        //help from: https://stackoverflow.com/questions/25511945/swift-alert-view-ios8-with-ok-and-cancel-button-which-button-tapped
        addDueDate.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in addDueDate.dismiss(animated: true, completion: nil)
        }))
        
        self.present(addDueDate, animated: true, completion: nil)
        
    }
    
    //-----------------------------------------------
    // createPickerView()
    //-----------------------------------------------
    // A function to create the UIPickerView and
    // place it on the view
    // Conditions: none
    //-----------------------------------------------
    func createPickerView() {
        view.addSubview(textField)
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(dateSelected(datePicker:)), for: .valueChanged)
        // add the DatePicker to the UITextField
        //textField.inputView = datePicker
        
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
        //textField.text = dateFormatter.string(from: datePicker.date)
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

//Reference for back icon used as button: https://freakycoder.com/ios-notes-4-how-to-set-background-image-programmatically-b377a8d4b50f
//Reference for adding a textfield to an alert:https://stackoverflow.com/questions/26567413/get-input-value-from-textfield-in-ios-alert-in-swift
