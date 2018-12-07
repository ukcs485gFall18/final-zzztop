//
//  ChoosePassViewController.swift
//  ios-midterm-2
//
//  Created by Adrienne Corwin on 10/21/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

class ChoosePassViewController: UIViewController, UITableViewDataSource {

    var userPasses: [String] = []
    var displayWidth = CGFloat()
    var displayHeight = CGFloat()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UserDefaults.standard.array(forKey: "userPasses") != nil) {
            userPasses = UserDefaults.standard.array(forKey: "userPasses") as! [String]
        } else {
            userPasses = [kPassTypes[21]]
        }
        
        // designes and positions views
        setupViews()
    }
    
    // dismisses a view
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }

    // changes status bar style to be light instead of dark
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupViews() {
        displayWidth = self.view.frame.width
        displayHeight = self.view.frame.height

        view.addSubview(tableView)
        view.addSubview(applyButton)

        let headerView = UIView(frame: CGRect(x:0, y: barHeight, width: displayWidth, height: headerHeight))
        headerView.backgroundColor = .black
        view.addSubview(headerView)
        headerView.addSubview(addPassesLabel)
        headerView.addSubview(backButton)
    }

    // creates table view
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: barHeight+headerHeight, width: displayWidth, height: displayHeight-headerHeight-buttonHeight-barHeight*2))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier:"passCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
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
        let addPassesLabel = UILabel(frame: CGRect(x: 0, y: ynavPadding, width: displayWidth-buttonWidth, height: buttonHeight))
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
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat{
        return 45
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

        let passString = kPassTypes[indexPath.row]
        //look in the dictionary of pass names and UIImages
        //put the value into the imageView
        let passImage = kPassImages[passString]
        cell.imageView?.image = passImage
        
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
}

// source for checkmarks on table view: https://www.youtube.com/watch?v=5MZ-WJuSdpg
// source for making status bar icons white: https://stackoverflow.com/questions/38740648/how-to-set-status-bar-style-in-swift-3
