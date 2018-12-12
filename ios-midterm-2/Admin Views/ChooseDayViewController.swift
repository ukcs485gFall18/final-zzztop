//
//  ChooseDayViewController.swift
//  ios-midterm-2
//
//  Created by Jordan George on 12/5/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import Static

class ChooseDayViewController: TableViewController {
    
    // MARK: - properties
    
    var options = [String]()
    var tag = Int()
    var count = 0
    
    // MARK: - initializers
    
    convenience init() {
        self.init(style: .grouped)
    }
    
    // MARK: - overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set options to chosen days in previous view
        options = chooseDayVC.options
        
        // designs and positions views
        setUpViews()
    }
    
    // designs and positions views
    func setUpViews() {
        title = "Choose Times for Specified Days"
        
        tableView.rowHeight = 50
        
        // Required to be set pre iOS11, to support autosizing
        tableView.estimatedSectionHeaderHeight = 13.5
        tableView.estimatedSectionFooterHeight = 13.5
        
        var sections = [Section]()
        
        count = 0
        for option in options {
            let section = Section(rows: [
                Row(text: option),
                Row(text: "Start Time:", selection: { [unowned self] in
                    self.updateTag()
                    }, cellClass: timesPickerTextFieldCell.self),
                Row(text: "End Time:", selection: { [unowned self] in
                    self.updateTag()
                    }, cellClass: timesPickerTextFieldCell.self)
                ])
            sections.append(section)
            count += 2
        }
        
        dataSource = DataSource(tableViewDelegate: self)
        dataSource.sections = sections
        
        // FIXME: not appearing
        view.addSubview(useButton)
        setUpUseButton()
    }
    
    // for updating tags
    func updateTag() {
        count += 1
        tag = count
    }
    
    // create use button
    lazy var useButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = red
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 23)
        button.addTarget(self, action: #selector(useThisTime), for: .touchUpInside)
        return button
    }()
    
    // position use button
    func setUpUseButton() {
        useButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        useButton.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        useButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        useButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 300).isActive = true // does not work as expected
    }
    
    // for later use
    @objc func useThisTime() {}
    
}

var chooseDayVC: ChooseDayViewController = ChooseDayViewController()

//todo:
//- tap gesture for tapping outside of cell text field
//- save times
//  - "use this time" button
//      -user defaults
//----------------
//later:
//- section headers not changing to day name correctly
