//
//  NewAdminViewController.swift
//  ios-midterm-2
//
//  Created by Jordan George on 12/4/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import Static

class SettingsViewController: TableViewController {
    
    // MARK: - initializers
    
    convenience init() {
        self.init(style: .grouped)
    }
    
    // MARK: - overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // remove buttons in nav bar from MapViewController
        let navsubviews = navigationController?.navigationBar.subviews
        let numofsubviews = navsubviews!.count
        if numofsubviews > 5 {
            let navbuttons = navsubviews![4...numofsubviews-1]
            for button in navbuttons {
                button.removeFromSuperview()
            }
        }
        
        title = "Settings"
        
        tableView.rowHeight = 50
        
        // Required to be set pre iOS11, to support autosizing
        tableView.estimatedSectionHeaderHeight = 13.5
        tableView.estimatedSectionFooterHeight = 13.5
        
        dataSource = DataSource(tableViewDelegate: self)
        dataSource.sections = [
            Section(header: "More Information", rows: [
                Row(text: "Parking Tickets", selection: { [unowned self] in
                    let ticketsVC = TicketsViewController();
                    self.present(ticketsVC, animated: true, completion: nil)
                    }, accessory: .disclosureIndicator),
                Row(text: "View parking info on UKY", selection: {
                    let ukParkingUrl = "https://www.uky.edu/transportation/parking-info"
                    guard let url = URL(string: ukParkingUrl) else { return }
                    UIApplication.shared.open(url)
                }, accessory: .disclosureIndicator)
                ]),
            Section(header: "Admin", rows: [
                Row(text: "Add parking spot", selection: { [unowned self] in
                    self.navigationController?.pushViewController(AddParkingViewController(), animated: true)
                    }, accessory: .disclosureIndicator),
                Row(text: "Edit parking spot", accessory: .disclosureIndicator),
                Row(text: "Delete parking spot", accessory: .disclosureIndicator)
                ], footer: "For admin use only.")
        ]
    }
    
}

extension TableViewController: UITableViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {}
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
}
