//
//  AdminViewController.swift
//  ios-midterm-2
//
//  Created by Jordan George on 11/30/18.
//  Copyright © 2018 Jordan George. All rights reserved.
//

import Foundation
import UIKit

class AdminViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // check if the user is logged in before allowing the user to make any admin changes
        checkIfUserIsLoggedIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    func checkIfUserIsLoggedIn() {
        present(LoginViewController(), animated: true, completion: nil)
    }
    
    
    
}
