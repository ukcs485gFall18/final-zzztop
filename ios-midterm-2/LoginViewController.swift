//
//  LoginViewController.swift
//  ios-midterm-2
//
//  Created by Jordan George on 11/30/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func alert(title: String = "", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func checkIfLoginCredentialsAreRight() {
        guard let username = usernameTextField.text,
            let password = passwordTextField.text else {
                print("Form is not valid")
                return
        }
        
        // set user defaults
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
        
        // get user default values (the username and password entered by the user)
        let attemptedUsername = UserDefaults.standard.string(forKey: "username")
        let attemptedPassword = UserDefaults.standard.string(forKey: "password")
        
        // set admin username and password
        let rightUsername = "Admin"
        let rightPassword = "123"

        // check if entered values are right
        if attemptedUsername == rightUsername || attemptedPassword == rightPassword {
            present(AdminViewController(), animated: true, completion: nil)
        } else {
            alert(title: "Login error", message: "Wrong username or password")
        }
    }
    
    
    @objc func closeViews() {
        print(123)
//        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - keyboard
    
    var activeTextField = UITextField()
    
    // creates bottom border
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // fix, temporary, keeps adding subviews instead of removing
        activeTextField.setBottomBorder(color: UIColor.white)
        
        activeTextField = textField
        activeTextField.setBottomBorder(color: red)
    }
    
    // Hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        
        // Switch focus to other text field
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: - views
    
    let red = UIColor(red: 250/255, green: 92/255, blue: 71/255, alpha: 1)
    let lightgray = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1).cgColor
    
    func setupViews() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(logo)
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(exitButton)
        
        setupLogo()
        setupUsernameTextField()
        setupPasswordTextField()
        setupLoginButton()
        setupExitButton()
    }
    
    lazy var logo: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    func setupLogo() {
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 200).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    lazy var usernameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = "Username"
        textField.backgroundColor = UIColor.white
        textField.tintColor = red
        textField.textAlignment = .center
        return textField
    }()
    
    func setupUsernameTextField() {
        usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usernameTextField.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 50).isActive = true
        usernameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5).isActive = true
        usernameTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = "Password"
        textField.backgroundColor = UIColor.white
        textField.tintColor = red
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        return textField
    }()
    
    func setupPasswordTextField() {
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 12).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = lightgray
        button.addTarget(self, action: #selector(checkIfLoginCredentialsAreRight), for: .touchUpInside)
        return button
    }()
    
    func setupLoginButton() {
        loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 12).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/5).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    lazy var exitButton: UIButton = {
        let img = UIImage(named: "exit")
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(img, for: .normal)
        button.addTarget(self, action: #selector(closeViews), for: .touchUpInside)
        return button
    }()
    
    func setupExitButton() {
        exitButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        exitButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        exitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        exitButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    }
   
}

extension UITextField {
    func setBottomBorder(color: UIColor) {
        self.borderStyle = UITextField.BorderStyle.none
        self.backgroundColor = UIColor.clear
        
        let line = UIView()
        let height = 1.0
        line.frame = CGRect(x: 0, y: Double(self.frame.height) - height, width: Double(self.frame.width), height: height)
        
        line.backgroundColor = color
        self.addSubview(line)
    }
}

// Source: my own code; looks similar to other login views I've made
// source: https://codepany.com/blog/swift-3-custom-uitextfield-with-single-line-input/
