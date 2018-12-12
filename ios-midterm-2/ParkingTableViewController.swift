//
//  ParkingTableViewController.swift
//  ios-midterm-2
//
//  Created by Adrienne Corwin on 12/1/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

class ParkingTableViewController: UIViewController, UITableViewDataSource {
    
    var parkingNames = [String]()
    var spotsAndTimes: [String: [[String: String]: [NSDictionary]]] = [:]
    var displayWidth = CGFloat()
    var displayHeight = CGFloat()
    let detailsVC = ParkingDetailsViewController()
    var pickedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // designs and positions views
        setUpViews()
    }
    
    // dismisses a view
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // changes status bar style to be light instead of dark
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //adds all of the lazy vars to the view and adds a header
    func setUpViews() {
        displayWidth = self.view.frame.width
        displayHeight = self.view.frame.height
        
        view.addSubview(tableView)
        //        view.addSubview(applyButton)
        
        let headerView = UIView(frame: CGRect(x:0, y: barHeight, width: displayWidth, height: headerHeight))
        headerView.backgroundColor = .black
        view.addSubview(headerView)
        headerView.addSubview(availableParkingLabel)
        headerView.addSubview(backButton)
    }
    
    // creates table view to hold UK pass options user can select from
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: barHeight+headerHeight, width: displayWidth, height: displayHeight-headerHeight))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier:"parkingCell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    // creates back button
    lazy var backButton: UIButton = {
        let backButton = UIButton(frame: CGRect(x: xPadding, y: ynavPadding*2, width: navButtonW/2, height: navButtonH))
        backButton.layer.cornerRadius = 5
        let backIcon = UIImage(named: "backIcon.png")
        backButton.setImage(backIcon, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return backButton
    }()
    
    // creates add pass label
    lazy var availableParkingLabel: UILabel = {
        let availableParkingLabel = UILabel(frame: CGRect(x: 0, y: ynavPadding, width: view.frame.width-buttonWidth, height: buttonHeight))
        availableParkingLabel.center.x = view.center.x
        availableParkingLabel.text = "Available Parking"
        availableParkingLabel.font = availableParkingLabel.font.withSize(headerFontSize)
        availableParkingLabel.textAlignment = NSTextAlignment.center
        availableParkingLabel.textColor = .white
        return availableParkingLabel
    }()
    
}

extension ParkingTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkingNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "parkingCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(parkingNames[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        detailsVC.pickedDate = pickedDate
        self.present(detailsVC,animated: true, completion: nil)
        if let hours = spotsAndTimes[parkingNames[indexPath.row]]{
            detailsVC.onUserAction(title: parkingNames[indexPath.row], hours: hours)
        }
    }
    
}
