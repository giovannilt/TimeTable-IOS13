//
//  TimeSheetController.swift
//  TimerSheet
//
//  Created by Giovanni La Torre on 13/07/2020.
//  Copyright © 2020 Giovanni La Torre. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ClockIn_OutController: UIViewController{
    
    let db = Firestore.firestore()
      
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
    }

}

//Mark: - NavigationBar

extension ClockIn_OutController{
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
           do {
               try Auth.auth().signOut()
               navigationController?.popToRootViewController(animated: true)
           } catch let signOutError as NSError {
             print ("Error signing out: %@", signOutError)
           }
    }
    
}



