//
//  Cells.swift
//  ios-midterm-2
//
//  Created by Jordan George on 12/5/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import Static

let vc: AddParkingViewController = AddParkingViewController()

extension TableViewController {
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

class regularTextFieldCell: UITableViewCell, Cell, UITextFieldDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(textField)
        setUpTextField()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        vc.name = textField.text!
    }
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    func setUpTextField() {
        textField.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        textField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        let c: CGFloat = 120
        textField.leftAnchor.constraint(equalTo: self.leftAnchor, constant: c).isActive = true
    }
    
}

class radiusPickerTextFieldCell: UITableViewCell, Cell, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let radiusItems = Array(65...75)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(textField)
        setUpTextField()
        textField.inputView = pickerView
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        vc.radius = Int(textField.text!)
    }
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    func setUpTextField() {
        textField.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        textField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        let c: CGFloat = 120
        textField.leftAnchor.constraint(equalTo: self.leftAnchor, constant: c).isActive = true
    }
    
    // MARK: picker view protocol config
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return radiusItems.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + radiusItems[0])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = "\(radiusItems[row])"
    }
    
}

class timesPickerTextFieldCell: UITableViewCell, Cell, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let timeItems: [[Any]] = [
        Array(1...12), // hours
        ["00", "30", "59"], // minutes
        ["AM", "PM"] // am/pm
    ]
    var hour = 1
    var min = "00"
    var ampm = "AM"
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(textField)
        setUpTextField()
        textField.inputView = pickerView
    }
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    func setUpTextField() {
        textField.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        textField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        let c: CGFloat = 120
        textField.leftAnchor.constraint(equalTo: self.leftAnchor, constant: c).isActive = true
    }
    
    // MARK: picker view protocol config
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return timeItems[0].count
        } else if component == 1 {
            return timeItems[1].count
        } else {
            return timeItems[2].count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let text = timeItems[0][row]
            return "\(text)"
        } else if component == 1 {
            let text = timeItems[1][row]
            return "\(text)"
        } else {
            let text = timeItems[2][row]
            return "\(text)"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            hour = timeItems[0][row] as! Int
        } else if component == 1 {
            min = timeItems[1][row] as! String
        } else {
            ampm = timeItems[2][row] as! String
        }
        textField.text = "\(hour):\(min) \(ampm)"
    }
    
}

class passPickerTextFieldCell: UITableViewCell, Cell, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let passItems = kPassTypes
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(textField)
        setUpTextField()
        textField.inputView = pickerView
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        vc.passtype = textField.text
    }
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    func setUpTextField() {
        textField.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        textField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        let c: CGFloat = 120
        textField.leftAnchor.constraint(equalTo: self.leftAnchor, constant: c).isActive = true
    }
    
    // MARK: picker view protocol config
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return passItems.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(passItems[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = "\(passItems[row])"
    }
    
}
