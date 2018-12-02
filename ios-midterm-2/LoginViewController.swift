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
    
    @objc func handleLoginButton() {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
                print("Form is not valid")
                return
        }
        
        if email == "Admin" && password == "123" {
            dismiss(animated: true, completion: nil)
        } else {
            alert(title: "Login error", message: "Wrong email or password")
        }
        
    }
    
    @objc func closeViews() {
        print(123)
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - keyboard
    
    // Hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        
        // Switch focus to other text field
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: - views
    
    func setupViews() {
        view.backgroundColor = UIColor.lightGray
        
        view.addSubview(logo)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(exitButton)
        
        setupLogo()
        setupEmailTextField()
        setupPasswordTextField()
        setupLoginButton()
        setupExitButton()
    }
    
    lazy var logo: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "AppIcon")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    func setupLogo() {
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 200).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = "Email"
        textField.textAlignment = .center
        textField.backgroundColor = UIColor.white
        return textField
    }()
    
    func setupEmailTextField() {
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 50).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.returnKeyType = .done
        textField.isSecureTextEntry = true
        textField.placeholder = "Password"
        textField.backgroundColor = .white
        textField.textAlignment = .center
        return textField
    }()
    
    func setupPasswordTextField() {
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12).isActive = true
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
        button.layer.borderColor = UIColor(red: 220, green: 220, blue: 220).cgColor
        button.addTarget(self, action: #selector(handleLoginButton), for: .touchUpInside)
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

extension UIColor {
    convenience init(red: Int = 0, green: Int = 0, blue: Int = 0, opacity: Int = 255) {
        precondition(0...255 ~= red   &&
            0...255 ~= green &&
            0...255 ~= blue  &&
            0...255 ~= opacity, "input range is out of range 0...255")
        self.init(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: CGFloat(opacity)/255)
    }
}


// Source: my own code; looks similar to other login views I've made

// FIXME: exit button
