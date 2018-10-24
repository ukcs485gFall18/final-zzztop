//
//  ChoosePassViewController.swift
//  ios-midterm-2
//
//  Created by Adrienne Corwin on 10/21/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

class ChoosePassViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var userPasses: [String] = []
    
    var barHeight = CGFloat()
    var displayWidth = CGFloat()
    var displayHeight = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UserDefaults.standard.array(forKey: "userPasses") != nil) {
            userPasses = UserDefaults.standard.array(forKey: "userPasses") as! [String]
        } else {
            userPasses = [kPassTypes[21]]
        }
        
        setupViews()
    }
    
    func setupViews() {
        displayWidth = self.view.frame.width
        displayHeight = self.view.frame.height
        barHeight =  UIApplication.shared.statusBarFrame.size.height
        
        let headerView = UIView(frame: CGRect(x:0, y: barHeight, width: displayWidth, height: 50))
        
        view.addSubview(tableView)
        view.addSubview(applyButton)
        view.addSubview(headerView)
        headerView.addSubview(backButton)
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: barHeight+50, width: displayWidth, height: displayHeight-2*barHeight-100))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier:"passCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        return tableView
    }()
    
    lazy var backButton: UIButton = {
        let backButton = UIButton(frame: CGRect(x: 20, y: 5, width: 60, height: 30))
        backButton.layer.cornerRadius = 5
        backButton.backgroundColor = .blue
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return backButton
    }()
    
    lazy var applyButton: UIButton = {
        let applyButton = UIButton(frame: CGRect(x: 25, y: displayHeight-80, width: displayWidth-50, height: 50))
        applyButton.layer.cornerRadius = 5
        applyButton.backgroundColor = .blue
        applyButton.setTitle("Apply", for: .normal)
        applyButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return applyButton
    }()
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - tableView functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kPassTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "passCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(kPassTypes[indexPath.row])"
        
        if userPasses.contains(cell.textLabel?.text ?? "") {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        
        if !userPasses.contains(kPassTypes[indexPath.row]) {
            userPasses.append(kPassTypes[indexPath.row])
            UserDefaults.standard.set(userPasses, forKey:"userPasses")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
        let removeIndex = userPasses.firstIndex(of:kPassTypes[indexPath.row])
        userPasses.remove(at: removeIndex!)
        UserDefaults.standard.set(userPasses, forKey: "userPasses")
    }
    
    var tableView: UITableView!
    var userPasses: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.standard.array(forKey: "userPasses") != nil){
            userPasses = UserDefaults.standard.array(forKey: "userPasses") as! [String]
        }
        else{
            userPasses = [kPassTypes[21]]
        }
        let barHeight:CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        let headerView = UIView(frame: CGRect(x:0, y:barHeight, width:displayWidth, height:50))
        let backButton = UIButton(frame: CGRect(x: 20, y: 5, width: 60, height: 30))
        backButton.layer.cornerRadius = 5
        backButton.backgroundColor = .blue
        backButton.setTitle("Back", for: .normal)
        
        let headerLabel = UILabel(frame: CGRect(x:headerView.center.x, y:headerView.center.y, width:200, height:50))
        headerLabel.center.x = headerView.center.x
        headerLabel.center.y = headerView.center.y
        headerLabel.text = "Add Your Passes"
        headerLabel.textAlignment = .center
        headerLabel.backgroundColor = .blue
        headerLabel.font = headerLabel.font.withSize(25)
        headerLabel.textColor = .white
        view.addSubview(headerLabel)

        let applyButton = UIButton(frame: CGRect(x: 25, y: displayHeight-80, width: displayWidth-50, height: 50))
        applyButton.layer.cornerRadius = 5
        applyButton.backgroundColor = .blue
        applyButton.setTitle("Apply", for: .normal)

        backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        applyButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        tableView = UITableView(frame: CGRect(x:0, y:barHeight+50, width:displayWidth, height:displayHeight-2*barHeight-100))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier:"passCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
//        let choosePassView = UIView(frame: CGRect(x: 10, y: 100, width: 300, height: 200))
        self.view.addSubview(self.tableView)
        headerView.addSubview(backButton)
        self.view.addSubview(headerView)
        self.view.addSubview(applyButton)
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}
