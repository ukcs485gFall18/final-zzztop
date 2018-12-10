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
    
    // MARK: - initializers
    
    convenience init() {
        self.init(style: .grouped)
    }
    
    // MARK: - overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        options = chooseDayVC.options
        options = ["MF","SS"]
        setUpViews()
    }
    
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
            count+=2
//            print(count)
        }
        
        dataSource = DataSource(tableViewDelegate: self)
        dataSource.sections = sections
    }
    var count = 0
    func updateTag() {
        count+=1
        tag = count
        print(tag)
    }
    
}

var chooseDayVC: ChooseDayViewController = ChooseDayViewController()


//todo:
//- tap gesture for tapping outside of cell text field
//- save times
    //- "use this time" button
        //-user defaults



//----------------
//later:
//- section headers not changing to day name correctly

