//
//  LoginViewController.swift
//  TimerSheet
//
//  Created by Giovanni La Torre on 13/07/2020.
//  Copyright © 2020 Giovanni La Torre. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate{
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        //GIDSignIn.sharedInstance().signIn()
        if userDefault.bool(forKey: "usersignedin") {
             self.performSegue(withIdentifier: K.loginSegue, sender: self)
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print (error.localizedDescription)
            let alert = UIAlertController(title: "Warning", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Go", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let e = error  {
                print (e.localizedDescription)
                let alert = UIAlertController(title: "Warning", message: e.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Go", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                // Navigate to ChatViewController
                self.userDefault.set(true, forKey: "usersignedin")
                self.userDefault.synchronize()
                self.performSegue(withIdentifier: K.loginSegue, sender: self)
            }
            return
        }
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.userDefault.set(false, forKey: "usersignedin")
            self.userDefault.synchronize()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url)
    }
    
}


