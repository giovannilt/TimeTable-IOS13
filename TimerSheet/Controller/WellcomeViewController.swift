//
//  ViewController.swift
//  TimerSheet
//
//  Created by Giovanni La Torre on 13/07/2020.
//  Copyright © 2020 Giovanni La Torre. All rights reserved.
//

import UIKit
import CLTypingLabel
import GoogleSignIn
import Firebase


class WellcomeViewController: UIViewController {
    let userDefault = UserDefaults.standard
    @IBOutlet weak var titleLabel: CLTypingLabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = K.appName
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            if self.userDefault.bool(forKey: "usersignedin") {
                GIDSignIn.sharedInstance().delegate = self
                self.performSegue(withIdentifier: K.loginSegue, sender: self)
            }
        }
    }
    
    
}

extension WellcomeViewController: GIDSignInDelegate{
    
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


