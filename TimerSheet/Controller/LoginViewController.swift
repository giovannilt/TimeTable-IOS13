//
//  LoginViewController.swift
//  TimerSheet
//
//  Created by Giovanni La Torre on 13/07/2020.
//  Copyright © 2020 Giovanni La Torre. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    

    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            Auth.auth().signIn(withEmail: email, password: password) {authResult, error in
              if let e = error  {
                print (e.localizedDescription)
                let alert = UIAlertController(title: "Warning", message: e.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Go", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
              } else {
                  // Navigate to ChatViewController
                self.performSegue(withIdentifier: K.loginSegue, sender: self)
              }
                
            }
        }
    }
    
}
