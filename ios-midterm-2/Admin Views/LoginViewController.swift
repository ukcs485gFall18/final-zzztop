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
        setUpViews()
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
            dismiss(animated: true, completion: nil)
        } else {
            // present alert
            let alertController = UIAlertController(title: "Login error", message: "Wrong username or password", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // FIXME: Views not dismissing correctly; would like to go back to settings view
    var count = 0
    @objc func closeViews() {
        count += 1
        print("in login vc, count==", count)
        
        self.presentingViewController?.dismiss(animated: true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismiss(animated: true, completion: {});
        }); // does not go back to root view
        //        dismiss(animated: true, completion: nil) //dismisses first/one view and is pulled back up since they're not logged in
        //        self.presentingViewController!.dismiss(animated: true, completion: nil) // dismisses first
        //        self.view.window?.rootViewController?.presentedViewController!.dismiss(animated: true, completion: nil) //dismisses first
    }
    
    // MARK: - keyboard
    
    var activeTextField = UITextField()
    
    // creates bottom border
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // temporary, keeps adding subviews instead of removing
        activeTextField.setBottomBorder(color: UIColor.white)
        
        activeTextField = textField
        activeTextField.setBottomBorder(color: red)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // temporary, need to remove subview
        activeTextField.setBottomBorder(color: UIColor.white)
    }
    
    // Hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // Switch focus to next text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: - views
    
    func setUpViews() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(logo)
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(exitButton)
        
        setUpLogo()
        setUpUsernameTextField()
        setUpPasswordTextField()
        setUpLoginButton()
        setUpExitButton()
    }
    
    lazy var logo: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    func setUpLogo() {
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
        textField.font = UIFont.systemFont(ofSize: tfFontSize)
        textField.textAlignment = .center
        textField.returnKeyType = .next
        return textField
    }()
    
    func setUpUsernameTextField() {
        usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usernameTextField.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 50).isActive = true
        usernameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5).isActive = true
        usernameTextField.heightAnchor.constraint(equalToConstant: tfHeight).isActive = true
    }
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = "Password"
        textField.backgroundColor = UIColor.white
        textField.tintColor = red
        textField.font = UIFont.systemFont(ofSize: tfFontSize)
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        return textField
    }()
    
    func setUpPasswordTextField() {
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: separation).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: tfHeight).isActive = true
    }
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = lightgray.cgColor
        button.addTarget(self, action: #selector(checkIfLoginCredentialsAreRight), for: .touchUpInside)
        return button
    }()
    
    func setUpLoginButton() {
        loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: separation).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/5).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: tfHeight).isActive = true
    }
    
    lazy var exitButton: UIButton = {
        let img = UIImage(named: "exit")
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(img, for: .normal)
        button.addTarget(self, action: #selector(closeViews), for: .touchUpInside)
        return button
    }()
    
    func setUpExitButton() {
        exitButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        exitButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        exitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        exitButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    }
   
}

// source: https://codepany.com/blog/swift-3-custom-uitextfield-with-single-line-input/
