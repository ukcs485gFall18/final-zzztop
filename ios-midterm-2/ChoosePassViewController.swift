//
//  ChoosePassViewController.swift
//  ios-midterm-2
//
//  Created by Adrienne Corwin on 10/21/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit


//view where user selects which passes they have

class ChoosePassViewController: UIViewController, UITableViewDataSource {

    var userPasses: [String] = []
    var displayWidth = CGFloat()
    var displayHeight = CGFloat()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // save user's pass information in user defaults so they only have to reselect if they want to change their information
        if (UserDefaults.standard.array(forKey: "userPasses") != nil) {
            userPasses = UserDefaults.standard.array(forKey: "userPasses") as! [String]
        } else {
            userPasses = [kPassTypes[21]] // if user has no pass, make their pass type no pass required
            UserDefaults.standard.set(userPasses, forKey: "userPasses") // set user defaults
        }
        
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
    
    func setUpViews() {
        displayWidth = self.view.frame.width
        displayHeight = self.view.frame.height

        view.addSubview(tableView)
        view.addSubview(applyButton)

        let headerView = UIView(frame: CGRect(x:0, y: barHeight, width: displayWidth, height: headerHeight))
        headerView.backgroundColor = .black
        view.addSubview(headerView)
        headerView.addSubview(addPassesLabel)
    }

    // creates table view to hold UK pass options user can select from
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: barHeight+headerHeight, width: displayWidth, height: displayHeight-headerHeight-buttonHeight-barHeight*2))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier:"passCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        return tableView
    }()
    
    // creates apply button
    lazy var applyButton: UIButton = {
        let applyButton = UIButton(frame: CGRect(x: 0, y: view.frame.height-buttonHeight-yPadding, width: displayWidth-xPadding*2, height: buttonHeight))
        applyButton.setTitleColor(.black, for: .normal)
        applyButton.alpha = 0.8
        applyButton.center.x = view.center.x
        applyButton.layer.cornerRadius = 5
        applyButton.backgroundColor = .white
        applyButton.setTitle("Apply", for: .normal)
        applyButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return applyButton
    }()

    // creates add pass label
    lazy var addPassesLabel: UILabel = {
        let addPassesLabel = UILabel(frame: CGRect(x: 0, y: ynavPadding, width: view.frame.width-buttonWidth, height: buttonHeight))
        addPassesLabel.center.x = view.center.x
        addPassesLabel.text = "Add Passes"
        addPassesLabel.font = addPassesLabel.font.withSize(headerFontSize)
        addPassesLabel.textAlignment = NSTextAlignment.center
        addPassesLabel.textColor = .white
        return addPassesLabel
    }()

}

// overrides table view functions
extension ChoosePassViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kPassTypes.count
    }

    // make each cell of table contain a pass name
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "passCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(kPassTypes[indexPath.row])"

        // if a user has selected that pass, leaves the view, and returns to view
        // the passes they selected previously will still be selected and have a checkmark by them
        if userPasses.contains(cell.textLabel?.text ?? "") {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }

        return cell
    }
    
    // if user selects a cell put a checkmark next to it and save it to user defaults
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        
        let passName = kPassTypes[indexPath.row]
        
        if !userPasses.contains(passName) { // so there aren't duplicate passes
            userPasses.append(passName)
            
            // check for special passes
            let firstCharacter = passName[0]
            if firstCharacter == "C" || firstCharacter == "R" {
                // if k lot is not already in userPasses
                let kLot = kPassTypes[15]
                if !userPasses.contains(kLot) {
                    // add check mark for k lot cell
                    tableView.cellForRow(at: [0, 15])?.accessoryType = UITableViewCell.AccessoryType.checkmark
                    // FIXME: make gray as well
                    // append k lot
                    userPasses.append(kLot)
                }
            }
            
            UserDefaults.standard.set(userPasses, forKey: "userPasses")
        }
    }

    // if user deselects a cell remove the checkmark and remove from user defaults
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
        let removeIndex = userPasses.firstIndex(of: kPassTypes[indexPath.row])
        userPasses.remove(at: removeIndex!)
        UserDefaults.standard.set(userPasses, forKey: "userPasses")
    }
}

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}

// source for getting nth character: https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language
// source for checkmarks on table view: https://www.youtube.com/watch?v=5MZ-WJuSdpg
// source for making status bar icons white: https://stackoverflow.com/questions/38740648/how-to-set-status-bar-style-in-swift-3
