//
//  TicketsViewController.swift
//  ios-midterm-2
//
//  Created by Kyra Seevers on 12/9/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

class TicketsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //array of all the tickets in user defaults
    var ticketsArrayRetrieved = [String]()
    //UI components
    private var myTableView: UITableView!
    let datePicker = UIDatePicker()
    let defaults = UserDefaults.standard
    
    //------------------------------
    //TableView Delegate Functions
    //------------------------------
    
    //Displays the amount of cells corresponding to the amount of tickets in user defaults
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ticketsArrayRetrieved = defaults.object(forKey: "TicketsArray") as? [String] ?? [String]()
        return ticketsArrayRetrieved.count
    }
    
    //Displays the tickets in user defaults in their individual table view cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        // references: https://stackoverflow.com/questions/27762236/line-breaks-and-number-of-lines-in-swift-label-programmatically/27762296
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel!.text = "\(ticketsArrayRetrieved[indexPath.row])"
        return cell
    }
    
    //sends the user to the approproate UK Transporation website based on pass selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // help from: https://stackoverflow.com/questions/25511945/swift-alert-view-ios8-with-ok-and-cancel-button-which-button-tapped
        let paidTicket = UIAlertController(title: "Alert", message: "Pay this parking ticket?", preferredStyle: .alert)
        paidTicket.addAction(UIAlertAction(title: "Pay", style: .default, handler: { action in
            switch action.style {
            case .default:
                self.ticketsArrayRetrieved = self.defaults.object(forKey: "TicketsArray") as? [String] ?? [String]()
                self.ticketsArrayRetrieved.remove(at: indexPath.row)
                self.defaults.set(self.ticketsArrayRetrieved, forKey: "TicketsArray")
                self.myTableView.reloadData()
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }}))
        paidTicket.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in paidTicket.dismiss(animated: true, completion: nil)
        }))
        self.present(paidTicket, animated: true, completion: nil)
        
    }
    
    //-----------------------------------------------
    // viewDidLoad()
    //-----------------------------------------------
    // A function to load the buttons and tableView
    // Conditions: none
    //-----------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting the background of this current view to white
        view.backgroundColor = .white
        
        // Created with help from https://stackoverflow.com/questions/40220905/create-uitableview-programmatically-in-swift
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: 90, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        
        // declaring and adding a back button to the view
        let backButton = UIButton(frame: CGRect(x: 20, y: 50, width: 30, height: 30))
        backButton.layer.cornerRadius = 5
        let backIcon = UIImage(named: "backIconBlack.png")
        backButton.setImage(backIcon, for: .normal)
        backButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        view.addSubview(backButton)
        
        // declaring and adding a back button to the view
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
    
    
    //-----------------------------------------------
    // createNewTicket()
    //-----------------------------------------------
    // A function to create a new parking ticket when
    // the plus button is tapped, storing it in user
    // defaults
    // Conditions: none
    //-----------------------------------------------
    @objc func createNewTicket(){
        let addDueDate = UIAlertController(title: "\n\n\n\n\n\n\n\n", message: "When is your ticket due?", preferredStyle: .alert)
        addDueDate.view.addSubview(datePicker)
        datePicker.frame = CGRect(x: 10, y: 0, width: 260, height: 200)
        addDueDate.addAction(UIAlertAction(title: "Submit", style: .default, handler: { action in
            switch action.style{
            case .default:
                var newTicket = "Created: "
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEEEEEE LLL d yyyy"
                newTicket = newTicket + dateFormatter.string(from: Date())
                newTicket = newTicket+"\nDue: "+dateFormatter.string(from: self.datePicker.date)
                self.ticketsArrayRetrieved = self.defaults.object(forKey: "TicketsArray") as? [String] ?? [String]()
                self.ticketsArrayRetrieved.append(newTicket)
                self.defaults.set(self.ticketsArrayRetrieved, forKey: "TicketsArray")
                self.myTableView.reloadData()
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }}))
        
        // help from: https://stackoverflow.com/questions/25511945/swift-alert-view-ios8-with-ok-and-cancel-button-which-button-tapped
        addDueDate.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in addDueDate.dismiss(animated: true, completion: nil)
        }))
        
        self.present(addDueDate, animated: true, completion: nil)
        
    }
    
}

// Reference for back icon used as button: https://freakycoder.com/ios-notes-4-how-to-set-background-image-programmatically-b377a8d4b50f
// Reference for adding a textfield to an alert:https://stackoverflow.com/questions/26567413/get-input-value-from-textfield-in-ios-alert-in-swift
// Reference for user defaults: https://www.hackingwithswift.com/example-code/system/how-to-save-user-settings-using-userdefaults
// Reference for removing from an array: https://stackoverflow.com/questions/24051633/how-to-remove-an-element-from-an-array-in-swift
